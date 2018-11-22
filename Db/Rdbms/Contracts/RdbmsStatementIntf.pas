{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RdbmsStatementIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    RdbmsResultSetIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handle relational database prepared statement operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IRdbmsStatement = interface
        ['{6CCC4179-DFB7-4DBD-A524-FFD36FBDE9FA}']

        (*!------------------------------------------------
         * execute statement
         *-------------------------------------------------
         * @return result set
         *-------------------------------------------------*)
        function execute() : IRdbmsResultSet;

        (*!------------------------------------------------
         * set parameter string value
         *-------------------------------------------------
         * @return current statement
         *-------------------------------------------------*)
        function paramStr(const strName : string; const strValue : string) : IRdbmsStatement;

        (*!------------------------------------------------
         * set parameter integer value
         *-------------------------------------------------
         * @return current statement
         *-------------------------------------------------*)
        function paramInt(const strName : string; const strValue : integer) : IRdbmsStatement;
    end;

implementation

end.
