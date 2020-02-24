{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ValidationTests;

interface

uses

    fpcunit,
    testregistry;

type

    TValidationTest = Class(TTestCase)
    published
        procedure TestAcceptedValidator;
    end;

implementation

uses

    Sysutils,
    StrUtils,
    RequestIntf,
    ValidatorIntf,
    ReadOnlyListIntf,
    MockRequestImpl,
    AcceptedValidatorImpl;

procedure TValidationTest.TestAcceptedValidator;
var
    validator : IValidator;
    request : IRequest;
    data : IReadOnlyList;
    res : boolean;
begin
    validator := TAcceptedValidator.create();
    request := TMockRequest.create();
    data := request.getParams();

    res := validator.valid('true', data, request);
    AssertEquals('Accept validator with value "true" must pass ', true, res);

    res := validator.valid('false', data, request);
    AssertEquals('Accept validator with value "false" must not pass ', false, res);

    res := validator.valid('1', data, request);
    AssertEquals('Accept validator with value "1" must pass ', true, res);

    res := validator.valid('0', data, request);
    AssertEquals('Accept validator with value "0" must not pass ', false, res);

    res := validator.valid('yes', data, request);
    AssertEquals('Accept validator with value "yes" must pass ', true, res);

    res := validator.valid('no', data, request);
    AssertEquals('Accept validator with value "no" must not pass ', false, res);

    res := validator.valid('on', data, request);
    AssertEquals('Accept validator with string "on" must pass ', true, res);

    res := validator.valid('off', data, request);
    AssertEquals('Accept validator with string "off" must not pass ', false, res);

end;


initialization
    RegisterTest(TValidationTest);
end.
