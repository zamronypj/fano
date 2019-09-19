{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AntivirusValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    RequestIntf,
    ValidatorIntf,
    AntivirusIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate field that uploaded file must be free from virus
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAntivirusValidator = class(TBaseValidator)
    private
        fAntivirus : IAntivirus;
        fOriginalErrMsg : string;
    protected
        (*!------------------------------------------------
         * actual data validation
         *-------------------------------------------------
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValidData(
            const dataToValidate : string;
            const dataCollection : IList;
            const request : IRequest
        ) : boolean; override;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------*)
        constructor create(const antivirus : IAntivirus);

        (*!------------------------------------------------
         * destructor
         *-------------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param fieldName name of field
         * @param dataToValidate input data
         * @param request request object
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValid(
            const fieldName : shortstring;
            const dataToValidate : IList;
            const request : IRequest
        ) : boolean; override;
    end;

implementation

uses

    UploadedFileIntf,
    ScanResultIntf;

resourcestring

    sErrFieldIsMustBeFreeFromVirus = 'Field %s must be a free from virus. ';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TAntivirusValidator.create(const antivirus : IAntivirus);
    begin
        inherited create(sErrFieldIsMustBeFreeFromVirus);
        fOriginalErrMsg := sErrFieldIsMustBeFreeFromVirus;
        fAntivirus := antivirus;
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param fieldName name of field
     * @param dataToValidate input data
     * @param request request object
     * @return true if data is valid otherwise false
     *-------------------------------------------------
     * We assume dataToValidate <> nil
     *-------------------------------------------------*)
    function TAntivirusValidator.isValid(
        const fieldName : shortstring;
        const dataToValidate : IList;
        const request : IRequest
    ) : boolean;
    var uploadedFile : IUploadedFile;
        scanRes : IScanResult;
    begin
        uploadedFile := request.getUploadedFile(fieldName);
        if (uploadedFile <> nil) then
        begin
            scanRes := fAntivirus.scanFile(uploadedFile.getTmpFilename());
            result := scanRes.isCleaned();
            if not result then
            begin
                errorMsgFormat := fOriginalErrMsg + ' Virus detected: ' + scanRes.virusName();
            end;
        end else
        begin
            //assume validation pass
            result := true;
        end;
    end;

    (*!------------------------------------------------
     * actual data validation
     *-------------------------------------------------
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TAntivirusValidator.isValidData(
        const dataToValidate : string;
        const dataCollection : IList;
        const request : IRequest
    ) : boolean;
    begin
        //not used here but we must implement, as this is abstract method
        result := true;
    end;
end.
