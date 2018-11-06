{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit EMethodNotAllowedImpl;

interface

{$MODE OBJFPC}

uses

    sysutils;

type

    (*!------------------------------------------------
     * Exception that is raised when request method
     * not allowed. For example route is registerd for POST
     * but route is requested with GET.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    EMethodNotAllowed = class(Exception)
    end;

implementation

end.
