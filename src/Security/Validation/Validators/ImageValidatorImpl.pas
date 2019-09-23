{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AlwaysPassValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ReadOnlyListIntf,
    RequestIntf,
    ValidatorIntf;

type

    (*!------------------------------------------------
     * dummy validation rule which always pass validation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAlwaysPassValidator = class(TInterfacedObject, IValidator)
    public

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
            const dataToValidate : IReadOnlyList;
            const request : IRequest
        ) : boolean;

        (*!------------------------------------------------
         * Get validation error message
         *-------------------------------------------------
         * @param key name of filed that is being validated
         * @return validation error message
         *-------------------------------------------------*)
        function errorMessage(const fieldName : shortstring) : string;
    end;

implementation

uses SysUtils, Classes, Graphics, GIFImg, JPEG, PngImage;

    const
    MinGraphicSize = 44; //we may test up to & including the 11th longword

    function FindGraphicType(
        const Buffer;
        const BufferSize: Int64;
        out GraphicClass: TGraphicClass
    ): Boolean; overload;
    var
        LongWords: array[Byte] of LongWord absolute Buffer;
        Words: array[Byte] of Word absolute Buffer;
    begin
        GraphicClass := nil;
        Result := False;
        if BufferSize < MinGraphicSize then Exit;
        case Words[0] of
            $4D42: GraphicClass := TBitmap;
            $D8FF: GraphicClass := TJPEGImage;
            $4949: if Words[1] = $002A then GraphicClass := TWicImage; //i.e., TIFF
            $4D4D: if Words[1] = $2A00 then GraphicClass := TWicImage; //i.e., TIFF
        else
            if Int64(Buffer) = $A1A0A0D474E5089 then
            GraphicClass := TPNGImage
            else if LongWords[0] = $9AC6CDD7 then
            GraphicClass := TMetafile
            else if (LongWords[0] = 1) and (LongWords[10] = $464D4520) then
            GraphicClass := TMetafile
            else if StrLComp(PAnsiChar(@Buffer), 'GIF', 3) = 0 then
            GraphicClass := TGIFImage
            else if Words[1] = 1 then
            GraphicClass := TIcon;
        end;
        result := (GraphicClass <> nil);
    end;

    (*!------------------------------------------------
     * Get validation error message
     *-------------------------------------------------
     * @return validation error message
     *-------------------------------------------------*)
    function TImageValidator.errorMessage(const fieldName : shortstring) : string;
    begin
        //not relevant because validation always passed
        result := '';
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param key name of field
     * @param dataToValidate input data
     * @param request request object
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TImageValidator.isValid(
        const fieldName : shortstring;
        const dataToValidate : IReadOnlyList;
        const request : IRequest
    ) : boolean;
    begin
        result := true;
    end;
end.
