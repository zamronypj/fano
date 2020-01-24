{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit WorkerThreadManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ThreadManagerImpl,
    WorkerThreadImpl;

type

    TWorkerThreadManager = specialize TThreadManager<TWorkerThread>;

implementation

end.
