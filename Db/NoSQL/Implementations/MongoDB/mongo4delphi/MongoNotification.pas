unit MongoNotification;

interface

uses
  Classes;

type
  TObjectNotification = class
  private
    FSubscriber: TNotifyEvent;
  protected
    procedure NotifyDestruction;
  public
    procedure FreeNotification(AEvent: TNotifyEvent);
    procedure RemoveFreeNotification;
    destructor Destroy; override;
  end;


implementation

{ TObjectNotification }

destructor TObjectNotification.Destroy;
begin
  NotifyDestruction;
  inherited;
end;

procedure TObjectNotification.FreeNotification(AEvent: TNotifyEvent);
begin
  FSubscriber := AEvent;
end;

procedure TObjectNotification.NotifyDestruction;
begin
  if Assigned(FSubscriber) then
  begin
    FSubscriber(Self);
  end;
end;

procedure TObjectNotification.RemoveFreeNotification;
begin
  FSubscriber := nil;
end;

end.
