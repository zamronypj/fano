{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ValidationResultTypes;

interface

{$MODE OBJFPC}
{$H+}

type
    TValidationMessage = record
        key : shortstring;
        errorMessage : string;
    end;
    TValidationMessages = array of TValidationMessage;

    TValidationResult = record
        isValid : boolean;
        errorMessages : TValidationMessages;
    end;

implementation

end.
