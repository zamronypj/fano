{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UploadedFileValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    RequestIntf,
    ValidatorIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate field that is a valid uploaded file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TUploadedFileValidator = class(TBaseValidator)
    protected
        (*!------------------------------------------------
         * actual data validation
         *-------------------------------------------------
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValidData(var dataToValidate : string) : boolean; override;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------*)
        constructor create();

        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param key name of field
         * @param dataToValidate input data
         * @param request request object
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
         function isValid(
             const key : shortstring;
             const dataToValidate : IList;
             const request : IRequest
         ) : boolean; override;
    end;

implementation

resourcestring

    sErrFieldIsUploadedFile = 'Field %s must be a valid uploaded file';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TUploadedFileValidator.create();
    begin
        inherited create(sErrFieldIsUploadedFile);
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param key name of field
     * @param dataToValidate input data
     * @param request request object
     * @return true if data is valid otherwise false
     *-------------------------------------------------
     * We assume dataToValidate <> nil
     *-------------------------------------------------*)
    function TUploadedFileValidator.isValid(
        const key : shortstring;
        const dataToValidate : IList;
        const request : IRequest
    ) : boolean;
    begin
        result := (request.getUploadedFile(key) <> nil);
    end;

    (*!------------------------------------------------
     * actual data validation
     *-------------------------------------------------
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TUploadedFileValidator.isValidData(const dataToValidate : string) : boolean;
    begin
        //not used here but we must implement as this is abstract method
        result := true;
    end;
end.
