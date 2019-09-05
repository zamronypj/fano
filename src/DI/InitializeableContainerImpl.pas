{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit InitializeableContainerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyContainerIntf;

type

    (*!------------------------------------------------
     * basic abstract IDependencyContainer implementation class
     * having capability to manage dependency and initialize services
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TInitializeableContainer = class(TInterfacedObject, IDependencyContainer)
    protected
        fActualContainer : IDependencyContainer;

        (*!--------------------------------------------------------
         * initialize application required services
         *---------------------------------------------------------
         * @param container dependency container
         *---------------------------------------------------------
         * Note: child class must provide its implementation
         *---------------------------------------------------------*)
        procedure initializeServices(const container : IDependencyContainer); virtual; abstract;
    public
        (*!--------------------------------------------------------
         * constructor
         *---------------------------------------------------------
         * @param container actual dependency container
         *---------------------------------------------------------*)
        constructor create(const container : IDependencyContainer);

        (*!--------------------------------------------------------
         * destructor
         *---------------------------------------------------------*)
        destructor destroy(); override;

        property serviceContainer : IDependencyContainer read fActualContainer implements IDependencyContainer;
    end;

implementation


    (*!--------------------------------------------------------
     * constructor
     *---------------------------------------------------------
     * @param cntr actual dependency container
     *---------------------------------------------------------*)
    constructor TInitializeableContainer.create(const container : IDependencyContainer);
    begin
        inherited create();
        fActualContainer := container;
        initializeServices(fActualContainer);
    end;

    (*!--------------------------------------------------------
     * destructor
     *---------------------------------------------------------*)
    destructor TInitializeableContainer.destroy();
    begin
        fActualContainer := nil;
        inherited destroy();
    end;

end.
