{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ImageGifValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    FileFormatValidatorImpl;

type

    (*!------------------------------------------------
     * validation rule which test if file upload is indeed
     * file image GIF
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TImageGifValidator = class(TFileFormatValidator)
    protected
        function isValidFormat(const buffer; const buffSize : int64) : boolean; override;
    end;

implementation

    function TImageGifValidator.isValidFormat(const buffer; const buffSize : int64) : boolean; override;
    begin
        result := (buffSize = MinBuffSize) and
            (strlcomp(PAnsiChar(@buffer), 'GIF', 3) = 0);
    end;

end.
