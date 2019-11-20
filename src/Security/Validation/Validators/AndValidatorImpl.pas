{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AndValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    CompositeValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate several validator with AND.
     * This is alias name for TCompositeValidator
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSameValidator = TCompositeValidator;

implementation
end.
