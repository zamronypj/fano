{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FirebirdDbImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RdbmsImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * handle Firebird relational database operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TFirebirdDb = class(TRdbms)
    end;

implementation

uses

    IBConnection;

end.
