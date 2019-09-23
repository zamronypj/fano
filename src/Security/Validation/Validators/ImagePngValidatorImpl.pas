{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ImagePngValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileFormatValidatorImpl;

type

    (*!------------------------------------------------
     * validation rule which test if file upload is indeed
     * file image PNG
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TImagePngValidator = class(TFileFormatValidator)
    protected
        function isValidFormat(const buffer; const buffSize : int64) : boolean; override;
    end;

implementation

const

    PNG_ID = $A1A0A0D474E5089;

    function TImagePngValidator.isValidFormat(const buffer; const buffSize : int64) : boolean; override;
    begin
        result := (buffSize = MinBuffSize) and (int64(buffer) = PNG_ID);
    end;

end.
