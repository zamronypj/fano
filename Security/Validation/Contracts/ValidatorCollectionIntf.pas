{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ValidatorCollectionIntf;

interface

{$MODE OBJFPC}

uses

    ValidatorIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * manage validator instances
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    IValidatorCollection = interface
        ['{D842D49C-09AF-4842-8712-B6C12AFB5C5B}']


        (*!------------------------------------------------
         * Add validator to collection
         *-------------------------------------------------
         * @param validator validator instance to add
         * @return current validator collection
         *-------------------------------------------------*)
        function add(const validator : IValidator) : IValidatorCollection;

        (*!------------------------------------------------
         * get number of validator in collection
         *-------------------------------------------------
         * @return current validator collection
         *-------------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get validator by index
         *-------------------------------------------------
         * @return validator instance
         *-------------------------------------------------*)
        function get(const indx : integer) : IValidator;
    end;

implementation

end.