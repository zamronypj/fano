{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit fano;

interface

{$MODE OBJFPC}

uses

    {$INCLUDE Includes/interfaces.inc}
    {$INCLUDE Includes/implementations.inc}
    {$INCLUDE Includes/types.inc}

type
    (*!-----------------------------------------------
     * Redeclare all classes in one unit to simplify
     * using classes in application code
     *-------------------------------------------------
     * If you use this unit, then you do not need to include
     * other unit otherwise you will get compilation error
     * about duplicate identifier
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)

    {$INCLUDE Includes/interfaces.aliases.inc}
    {$INCLUDE Includes/implementations.aliases.inc}

implementation

end.
