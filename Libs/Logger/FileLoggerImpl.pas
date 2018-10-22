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
    public
        (*!--------------------------------------
         * constructor
         * --------------------------------------
         * @param filename file to store logs
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
            const level : TLogLevel;
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
     * constructor
     * --------------------------------------
     * @param filename file to store logs
     * --------------------------------------
     * if file exists, we open file for append
     * if not then we create new. User who run
     * must have proper file permissions
     *---------------------------------------*)
    constructor TFileLogger.create(const filename : string);
    begin
        assignFile(outputFile, filename);
        if (fileExists(filename)) then
        begin
            append(outputFile);
        end else
        begin
            rewrite(outputFile);
        end;
        flushCounter := 0;
    end;

    (*!--------------------------------------
     * destructor
     * --------------------------------------
     * close file
     *---------------------------------------*)
    destructor TFileLogger.destroy();
    begin
        closeFile(outputFile);
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
        writeln(outputFile, '[', level,'] ', DateTimeToStr(Now), ' ', msg);
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
