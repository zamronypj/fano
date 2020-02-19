{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EUnauthorizedImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    EFanoExceptionImpl;

type

    (*!------------------------------------------------
     * Exception that is raised when user unauthorized
     * to access resource.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    EUnauthorized = class(EFanoException);

implementation

end.
