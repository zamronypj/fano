{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit FileLoggerImpl;

interface

{$H+}

(*!------------------------------------------------
 * turn on I/O checking so EInOutError will be raised
 * if file I/O operation is failed
 *-----------------------------------------------*)
{$I+}

uses

    sysutils,
    DependencyIntf,
    SerializeableIntf,
    LoggerIntf,
    AbstractLoggerImpl;

type

    (*!------------------------------------------------
     * logger class that write log to text file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFileLogger = class(TAbstractLogger, IDependency, ILogger)
    private
        outputFile : TextFile;
        flushCounter : integer;
        isOpen : boolean;

        (*!--------------------------------------
         * try opening file
         * --------------------------------------
         * @param filename file to open
         * @throws EInOutError
         *---------------------------------------*)
        procedure tryOpenFileOrExcept(const filename : string);

    public
        (*!--------------------------------------
         * constructor
         * --------------------------------------
         * @param filename file to store logs
         * @throws EInOutError
         *---------------------------------------*)
        constructor create(const filename : string);

        (*!--------------------------------------
         * destructor
         * --------------------------------------
         * @param filename file to store logs
         *---------------------------------------*)
        destructor destroy(); override;

        (*!--------------------------------------
         * log message
         * --------------------------------------
         * @param level type of log
         * @param msg log message
         * @param context data related to log message
         *               (if any)
         * @return current instance
         *---------------------------------------*)
        function log(
            const level : string;
            const msg : string;
            const context : ISerializeable = nil
        ) : ILogger; override;
    end;

implementation

const

    (*!--------------------------------------
     * number of time before we flush data to file
     *---------------------------------------*)
    FLUSH_AFTER = 500;

    (*!--------------------------------------
     * try opening file
     * --------------------------------------
     * @param filename file to open
     * @throws EInOutError
     *---------------------------------------*)
    procedure TFileLogger.tryOpenFileOrExcept(const filename : string);
    begin
        try
            if (fileExists(filename)) then
            begin
                append(outputFile);
            end else
            begin
                rewrite(outputFile);
            end;
        except
            on e : EInOutError do
            begin
                //original error message is not very clear
                //as it does not include file information,
                //here handle it and re raise exception with more clear message
                raise EInOutError.create(e.message + ' ' + filename);
            end;
        end;
    end;

    (*!--------------------------------------
     * constructor
     * --------------------------------------
     * @param filename file to store logs
     * @throws EInOutError
     * --------------------------------------
     * if file exists, we open file for append
     * if not then we create new. User who run
     * must have proper file permissions
     * If file can not be open, EInOutError exception
     * is raised
     *---------------------------------------*)
    constructor TFileLogger.create(const filename : string);
    begin
        isOpen := false;
        assignFile(outputFile, filename);

        tryOpenFileOrExcept(filename);

        //tryOpenFileOrExcept() will throw EInOutError when
        //failed. If we get here then, I/O operation is successful
        flushCounter := 0;
        isOpen := true;
    end;

    (*!--------------------------------------
     * destructor
     * --------------------------------------
     * close file if open
     *---------------------------------------*)
    destructor TFileLogger.destroy();
    begin
        inherited destroy();
        if (isOpen) then
        begin
            //file is open succesfully, so close it properly
            closeFile(outputFile);
        end;
    end;

    (*!--------------------------------------
     * log message
     * --------------------------------------
     * @param level type of log
     * @param msg log message
     * @param context data related to log message
     *               (if any)
     * @return current instance
     * --------------------------------------
     * Here we will flush message to file every
     * 500 call to log()
     *---------------------------------------*)
    function TFileLogger.log(
        const level : string;
        const msg : string;
        const context : ISerializeable = nil
    ) : ILogger;
    begin
        writeln(
            outputFile,
            '[', level,'] ',
            FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
            ' ',
            msg
        );
        if (context <> nil) then
        begin
            writeln(outputFile, '==== Start context ====');
            writeln(outputFile, context.serialize());
            writeln(outputFile, '==== End context ====');
        end;

        inc(flushCounter);
        if (flushCounter > FLUSH_AFTER) then
        begin
            flush(outputFile);
            flushCounter := 0;
        end;

        result := self;
    end;

end.
