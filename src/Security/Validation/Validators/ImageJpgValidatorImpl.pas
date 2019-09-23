{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ImageJpgValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileFormatValidatorImpl;

type

    (*!------------------------------------------------
     * validation rule which test if file upload is indeed
     * file image JPEG
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TImageJpgValidator = class(TFileFormatValidator)
    protected
        function isValidFormat(const buffer; const buffSize : int64) : boolean; override;
    end;

implementation

const

    JPEG_ID = $D8FF;

    function TImageJpgValidator.isValidFormat(const buffer; const buffSize : int64) : boolean; override;
    var
        words: array[byte] of word absolute buffer;
    begin
        result := (buffSize = MinBuffSize) and (words[0] = JPEG_ID);
    end;

end.
