{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit EInvalidRequestImpl;

interface

{$MODE OBJFPC}

uses

    sysutils;

type

    (*!------------------------------------------------
     * Exception that is raised when request is invalid
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    EInvalidRequest = class(Exception)
    end;

implementation

end.
