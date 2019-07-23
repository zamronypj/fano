{***************************************************************************}
{                                                                           }
{                    Mongo Delphi Driver                                    }
{                                                                           }
{           Copyright (c) 2012 Fabricio Colombo                             }
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
unit QueryBuilder;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses BsonTypes;

type
  TQueryOperators = (qoGreaterThan,
                     qoGreaterThanEquals,
                     qoLessThan,
                     qoLessThanEquals,
                     qoNotEquals,
                     qoIn,
                     qoNotIn,
                     qoMod,
                     qoAll,
                     qoSize,
                     qoExists,
                     qoWhere,
                     qoNear);

  TBsonTypes = (btDouble,
                btString,
                btObject,
                btArray,
                btBinary,
                btObjectId,
                btBoolean,
                btDate,
                btNull,
                btRegularExpression,
                btJavaScriptCode,
                btSymbol,
                btJavaScriptCodeWithScope,
                btinteger,
                btTimestamp,
                btInt64,
                btMinKey,
                btMaxKey);

const
  QO_GREATER_THAN = '$gt';
  QO_GREATER_THAN_EQUAL = '$gte';
  QO_LESS_THAN = '$lt';
  QO_LESS_THAN_EQUAL = '$lte';

type
  TQueryBuilder = class
  private
    FQuery: IBSONObject;
    FCurrentKey: String;

    function putKey(key: String): TQueryBuilder;
  protected
    constructor Create;
  public
    class function empty(): TQueryBuilder;
    class function query(key: String): TQueryBuilder;

    function build: IBSONObject;
    function buildAndFree: IBSONObject;

    function equals(value: Variant): TQueryBuilder;
    function andField(key: String): TQueryBuilder;
    function greaterThan(value: Variant): TQueryBuilder;
    function greaterThanEquals(value: Variant): TQueryBuilder;
    function lessThan(value: Variant): TQueryBuilder;
    function lessThanEquals(value: Variant): TQueryBuilder;
    function between(startValue, endValue: Variant): TQueryBuilder;

    (*
    see http://www.mongodb.org/display/DOCS/Advanced+Queries

    function all(): TQueryBuilder;
    function exists(): TQueryBuilder;
    function inOp(): TQueryBuilder;
    function isOp(): TQueryBuilder;

    function modOp(): TQueryBuilder;
    function notEquals(): TQueryBuilder;
    function notIn(): TQueryBuilder;
    function orOp(): TQueryBuilder;
    function size(): TQueryBuilder;
    function typeOp(AType: TBsonTypes): TQueryBuilder;
    function regex(): TQueryBuilder;

    see http://www.mongodb.org/display/DOCS/Geospatial+Indexing

    function nearOp(x, y: Double): TQueryBuilder;overload;
    function nearOp(x, y, maxDistance: Double): TQueryBuilder;overload;
    function withinBox(x, y, x2, y2: Double): TQueryBuilder;
    function withinCenter(x, y, radius: Double): TQueryBuilder;
    function withinPolygon(APolygon: IBSONObject): TQueryBuilder;
    *)
  end;

implementation

uses Variants;

{ TQueryBuilder }

function TQueryBuilder.andField(key: String): TQueryBuilder;
begin
  Result := putKey(key);
end;

function TQueryBuilder.between(startValue,endValue: Variant): TQueryBuilder;
begin
  FQuery.Put(FCurrentKey, TBSONObject.EMPTY()
                                     .Put(QO_GREATER_THAN_EQUAL, startValue)
                                     .Put(QO_LESS_THAN_EQUAL, endValue));

  Result := Self;
end;

function TQueryBuilder.build: IBSONObject;
begin
  Result := FQuery;
end;

function TQueryBuilder.buildAndFree: IBSONObject;
begin
  Result := build;

  Free;
end;

constructor TQueryBuilder.Create;
begin
  FQuery := TBSONObject.Create;
end;

class function TQueryBuilder.empty: TQueryBuilder;
begin
  Result := TQueryBuilder.Create;
end;

function TQueryBuilder.equals(value: Variant): TQueryBuilder;
begin
  FQuery.Put(FCurrentKey, value);

  Result := Self;
end;

function TQueryBuilder.greaterThan(value: Variant): TQueryBuilder;
begin
  FQuery.Put(FCurrentKey, TBSONObject.NewFrom(QO_GREATER_THAN, value));

  Result := Self;
end;

function TQueryBuilder.greaterThanEquals(value: Variant): TQueryBuilder;
begin
  FQuery.Put(FCurrentKey, TBSONObject.NewFrom(QO_GREATER_THAN_EQUAL, value));

  Result := Self;
end;

function TQueryBuilder.lessThan(value: Variant): TQueryBuilder;
begin
  FQuery.Put(FCurrentKey, TBSONObject.NewFrom(QO_LESS_THAN, value));

  Result := Self;
end;

function TQueryBuilder.lessThanEquals(value: Variant): TQueryBuilder;
begin
  FQuery.Put(FCurrentKey, TBSONObject.NewFrom(QO_LESS_THAN_EQUAL, value));

  Result := Self;
end;

function TQueryBuilder.putKey(key: String): TQueryBuilder;
begin
  FQuery.Put(key, Null);
  FCurrentKey := key;

  Result := Self;
end;

class function TQueryBuilder.query(key: String): TQueryBuilder;
begin
  Result := TQueryBuilder.Create;

  Result.putKey(key);
end;

end.
