{******************************************************************************}
{                                                                              }
{  Delphi FB4D Library                                                         }
{  Copyright (c) 2018-2019 Christoph Schneider                                 }
{  Schneider Infosystems AG, Switzerland                                       }
{  https://github.com/SchneiderInfosystems/FB4D                                }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}

unit FB4D.Configuration;

interface

uses
  System.Classes, System.SysUtils, System.Types,
  System.JSON, System.JSON.Types,
  System.Net.HttpClient,
  System.Generics.Collections,
  REST.Types,
  FB4D.Interfaces;

type
  /// <summary>
  /// The interface IFirebaseConfiguration provides a class factory for
  /// accessing all interfaces to the Firebase services.
  /// </summary>
  TFirebaseConfiguration = class(TInterfacedObject, IFirebaseConfiguration)
  private
    fApiKey: string;
    fProjectID: string;
    fBucket: string;
    fAuth: IFirebaseAuthentication;
    fRealTimeDB: IRealTimeDB;
    fDatabase: IFirestoreDatabase;
    fStorage: IFirebaseStorage;
    fFunctions: IFirebaseFunctions;
  public
    /// <summary>
    /// The first constructor requires all secrets of the Firebase project as
    /// ApiKey and Project ID and when using the Storage also the storage Bucket
    /// as parameter.
    /// </summary>
    constructor Create(const ApiKey, ProjectID: string;
      const Bucket: string = ''); overload;

    /// <summary>
    /// The second constructor parses the google-services.json file that shall
    /// be loaded from the Firebase Console after adding an App in the project
    /// settings.
    /// </summary>
    constructor Create(const GoogleServicesFile: string); overload;

    function Auth: IFirebaseAuthentication;
    function RealTimeDB: IRealTimeDB;
    function Database: IFirestoreDatabase;
    function Storage: IFirebaseStorage;
    function Functions: IFirebaseFunctions;
  end;

implementation

uses
  System.IOUtils,
  FB4D.Authentication, FB4D.RealTimeDB, FB4D.Firestore, FB4D.Storage,
  FB4D.Functions;

{ TFirebaseConfiguration }

constructor TFirebaseConfiguration.Create(const ApiKey, ProjectID,
  Bucket: string);
begin
  fApiKey := ApiKey;
  fProjectID := ProjectID;
  fBucket := Bucket;
end;

constructor TFirebaseConfiguration.Create(const GoogleServicesFile: string);
var
  JsonObj, ProjInfo: TJSONValue;
  Client, ApiKey: TJSONArray;
begin
  if not FileExists(GoogleServicesFile) then
    raise EFirebaseConfiguration.CreateFmt(
      'Open the Firebase Console and store the google-services.json here: %s',
      [ExpandFileName(GoogleServicesFile)]);
  JsonObj := TJSONObject.ParseJSONValue(TFile.ReadAllText(GoogleServicesFile));
  try
    ProjInfo := JsonObj.GetValue<TJSONObject>('project_info');
    Assert(assigned(ProjInfo), '"project_info" missing in Google-Services.json');
    fProjectID := ProjInfo.GetValue<string>('project_id');
    fBucket := ProjInfo.GetValue<string>('storage_bucket');
    Client := JsonObj.GetValue<TJSONArray>('client');
    Assert(assigned(Client), '"client" missing in Google-Services.json');
    Assert(Client.Count > 0, '"client" array empty in Google-Services.json');
    ApiKey := Client.Items[0].GetValue<TJSONArray>('api_key');
    Assert(assigned(ApiKey), '"api_key" missing in Google-Services.json');
    Assert(ApiKey.Count > 0, '"api_key" array empty in Google-Services.json');
    fApiKey := ApiKey.Items[0].GetValue<string>('current_key');
  finally
    JsonObj.Free;
  end;
end;

function TFirebaseConfiguration.Auth: IFirebaseAuthentication;
begin
  Assert(not fApiKey.IsEmpty, 'ApiKey is required for Authentication');
  if not assigned(fAuth) then
    fAuth := TFirebaseAuthentication.Create(fApiKey);
  result := fAuth;
end;

function TFirebaseConfiguration.RealTimeDB: IRealTimeDB;
begin
  Assert(not fProjectID.IsEmpty, 'ProjectID is required for RealTimeDB');
  if not assigned(fRealTimeDB) then
    fRealTimeDB := TRealTimeDB.Create(fProjectID, Auth);
  result := fRealTimeDB;
end;

function TFirebaseConfiguration.Database: IFirestoreDatabase;
begin
  Assert(not fProjectID.IsEmpty, 'ProjectID is required for Firestore');
  if not assigned(fDatabase) then
    fDatabase := TFirestoreDatabase.Create(fProjectID, fAuth);
  result := fDatabase;
end;

function TFirebaseConfiguration.Storage: IFirebaseStorage;
begin
  Assert(not fBucket.IsEmpty, 'Bucket is required for Storage');
  if not assigned(fStorage) then
    fStorage := TFirebaseStorage.Create(fBucket, fAuth);
  result := fStorage;
end;

function TFirebaseConfiguration.Functions: IFirebaseFunctions;
begin
  Assert(not fProjectID.IsEmpty, 'ProjectID is required for Functions');
  if not assigned(fFunctions) then
    fFunctions := TFirebaseFunctions.Create(fProjectID, fAuth);
  result := fFunctions;
end;

end.
