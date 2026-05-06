program opensslget;

{$mode objfpc}{$H+}
{$Packrecords C}

uses
  SysUtils, sockets, resolve, openssl;

type
  PSSL_CIPHER = ^SSL_CIPHER;
  // https://github.com/openssl/openssl/blob/ed4a71d18d939f557b430c4369d118b55c1c0b6c/ssl/ssl_local.h#L397
  SSL_CIPHER = record
    valid: LongWord;
    name: PChar;
    stdname: PChar;
    id: packed array[0..1] of Char;
    algorithm_mkey: LongWord;
    algorithm_auth: LongWord;
    algorithm_enc: LongWord;
    algorithm_mac: LongWord;
    min_tls: Integer;
    max_tls: Integer;
    min_dtls: Integer;
    max_dtls: Integer;
    algo_strength: LongWord;
    algorithm2: LongWord;
    strength_bits: LongInt;
    alg_bits: LongWord;
  end;

const
  // The read functions work based on the SSL/TLS records. The data are received in records (with a maximum record size of 16kB)
  // For TLS 1.2 and earlier, that limit is 2^14 octets. TLS 1.3 uses a limit of 2^14+1 octets.
  // https://www.rfc-editor.org/rfc/rfc8449.html#section-4
  BUF_SIZE = 16 * 1024;

  Host = 'example.org';
  Port = 443;

  {$IFDEF WINDOWS}
  ext = '.dll';
  {$ELSE}
  ext = '.so.3';
  {$ENDIF}

var
  filepath, trustedCertFile: string;
  //OpenSSL
  ctx: PSSL_CTX;
  ssl: PSSL;
  cipherPtr: PSSL_CIPHER;
  server_cert:pX509;
  in_buf: array[0..BUF_SIZE - 1] of char;
  request: string;
  nbytes_written, nbytes_read, ssl_error: integer;
  cert_str: AnsiString;
  tempBuf: AnsiString;
  //Sockets
  CSocket: TSocket;
  Address: TInetSockAddr;
  IPAddr: string;
  hrs: THostResolver;

procedure PrintSSLCipherInfo(const cipher: SSL_CIPHER);
begin
  Writeln('Cipher Name: ', cipher.name);
  Writeln('RFC Name: ', cipher.stdname);
  // https://www.iana.org/assignments/tls-parameters/tls-parameters.xhtml#tls-parameters-4
  Writeln('TLS Cipher ID: ', '0x' + IntToHex(Ord(cipher.id[1]), 2) + ', 0x' + IntToHex(Ord(cipher.id[0]), 2));
  Writeln('Key Exchange Algorithm: ', cipher.algorithm_mkey);
  Writeln('Server Authentication Algorithm: ', cipher.algorithm_auth);
  Writeln('Symmetric Encryption Algorithm: ', cipher.algorithm_enc);
  Writeln('Symmetric Authentication Algorithm: ', cipher.algorithm_mac);
  Writeln('Minimum SSL/TLS Protocol Version: ', cipher.min_tls);
  Writeln('Maximum SSL/TLS Protocol Version: ', cipher.max_tls);
  Writeln('Minimum DTLS Protocol Version: ', cipher.min_dtls);
  Writeln('Maximum DTLS Protocol Version: ', cipher.max_dtls);
  Writeln('Strength and Export Flags: ', cipher.algo_strength);
  Writeln('Extra Flags: ', cipher.algorithm2);
  Writeln('Number of Bits Used: ', cipher.strength_bits);
  Writeln('Number of Bits for Algorithm: ', cipher.alg_bits);
end;

begin
  filepath := ExtractFilePath(ParamStr(0));
  // https://curl.se/ca/cacert.pem
  trustedCertFile := filepath + 'cacert.pem';
  // Load OpenSSL dynamic libraries from program folder
  InitSSLInterface(filepath + 'libssl' + ext, filepath + 'libcrypto' + ext);

  // Show libs version https://github.com/openssl/openssl/blob/8f51b2279eda1e0cffb3400c2e5b5c3771f62ea7/include/openssl/crypto.h.in#L162
  WriteLn('OpenSSL version: ' + OpenSSLGetVersion(7)); // OPENSSL_FULL_VERSION_STRING

  // Create an SSL context.
  ctx := SSLCTXnew(SslTLSMethod);
  if not Assigned(ctx) then
  begin
    WriteLn('Could not create SSL context');
    Halt(1);
  end;

  // Load trusted certificates.
  if SSLCTXloadverifylocations(ctx, PChar(trustedCertFile), '') <= 0 then
    begin
      WriteLn('Could not load trusted certificates');
      Halt(1);
    end;

  // Set verification options.
  SSLCTXsetverify(ctx, SSL_VERIFY_PEER, nil);
  SSLCTXsetmode(ctx, SSL_MODE_AUTO_RETRY);

  // Create SSL connection
  ssl := SSLnew(ctx);
  if ssl = nil then
  begin
    Writeln('Error creating SSL connection');
    Halt(1);
  end;

  // Create simple socket
  CSocket := fpsocket(AF_INET, SOCK_STREAM, 0);
  if CSocket = -1 then
  begin
    WriteLn('Error creating socket');
    Halt(1);
  end;

  // Resolve domain name to IP adress
  hrs := THostResolver.Create(nil);
  if hrs.NameLookup(Host) then
  begin
    IPAddr := hrs.AddressAsString;
    WriteLn('Resolved IP Address: ', IPAddr);
  end
  else
  begin
    WriteLn('Failed to resolve the hostname: ', Host);
    Halt(1);
  end;

  // Connect to host
  with Address do
   begin
      sin_family := AF_INET; //TCP/IP
      sin_port:= htons(word(Port)); //Port
      sin_addr:=StrToNetAddr(hrs.AddressAsString); // IP address
   end;

  hrs.Free;

  if fpconnect(CSocket, @Address, SizeOf(Address)) < 0 then
  begin
    WriteLn('Error connecting to server.');
    Halt(1);
  end;

  writeln('Connected ', Host, ':', Port);

  // Set file descriptor (fd) of connected socket to SSL connection
  SSLsetfd(ssl, CSocket);

  // Establish SSL connection
  if SslConnect(ssl) <= 0 then
  begin
    Writeln('SSL connection error.');
    Halt(1);
  end;
  Writeln('SSL connection established.');
  WriteLn('----' + #13#10 + 'SSL connection cipher description:');
  // https://www.openssl.org/docs/manmaster/man3/SSL_get_cipher.html
  cipherPtr := SSLgetcurrentcipher(ssl);
  PrintSSLCipherInfo(cipherPtr^);
  WriteLn('----');
  // https://www.openssl.org/docs/manmaster/man3/SSL_get_version.html
  WriteLn('SSL/TLS version: ' + SslGetVersion(ssl));
  WriteLn('----');
  // https://www.openssl.org/docs/manmaster/man3/SSL_get_peer_certificate.html
  server_cert := SslGetPeerCertificate(ssl);
  WriteLn('Server certificate:');
  SetLength(tempBuf, 1024);
  // https://www.openssl.org/docs/man3.0/man3/X509_NAME_oneline.html
  // https://www.openssl.org/docs/manmaster/man3/X509_get_subject_name.html
  cert_str := X509NameOneline(X509GetSubjectName(server_cert), tempBuf, Length(tempBuf));
  cert_str := StringReplace(cert_str, '\xC2\xA0', ' ', [rfReplaceAll]);
  WriteLn('Subject: ', cert_str);
  // https://www.openssl.org/docs/manmaster/man3/X509_get_issuer_name.html
  cert_str := X509NameOneline(X509GetIssuerName(server_cert), tempBuf, Length(tempBuf));
  cert_str := StringReplace(cert_str, '\xC2\xA0', ' ', [rfReplaceAll]);
  WriteLn('Issuer: ', cert_str + #13#10);

  // We could do all sorts of certificate verification stuff here before deallocating the certificate
  // https://www.openssl.org/docs/manmaster/man3/X509_free.html
  X509free(server_cert);

  // Create an HTTP GET request.
  request :=
    'GET / HTTP/1.1'#13#10 +
    'Host: ' + Host + #13#10 +
    'Connection: close'#13#10 +
    'User-Agent: Example TLS client'#13#10#13#10;

  // Send the request to the server.
  WriteLn('--> Sending to the server:');
  Write(request);
  // https://www.openssl.org/docs/manmaster/man3/SSL_write.html
  nbytes_written := SslWrite(ssl, PChar(request), Length(request));
  if nbytes_written <> Length(request) then
  begin
    WriteLn('Could not send all data to the server');
    Halt(1);
  end;

  WriteLn('--> Sending to the server finished');
  WriteLn('<-- Receiving from the server:');

  // Receive and display the server's response.
  repeat
    // https://www.openssl.org/docs/manmaster/man3/SSL_read.html
    nbytes_read := SslRead(ssl, @in_buf, BUF_SIZE);
    if nbytes_read <= 0 then
    begin
      ssl_error := SSLgeterror(ssl, nbytes_read);
      if ssl_error = SSL_ERROR_ZERO_RETURN then
        Break
      else
      begin
        WriteLn('Error ', ssl_error, ' while reading data from the server');
        Halt(1);
      end;
    end;

    Write(UTF8Encode(Copy(in_buf, 0, nbytes_read)));
  until False;

  WriteLn('<-- Receiving from the server finished');

  // Send SSL/TLS close_notify
  // https://www.openssl.org/docs/manmaster/man3/SSL_shutdown.html
  repeat
    ssl_error := SslShutdown(ssl);
  until ssl_error <> 0;

  if ssl_error = 1 then
      WriteLn('SSL connection sussefully closed.')
    else
      // https://www.openssl.org/docs/manmaster/man3/SSL_get_error.html
      WriteLn('SSL connection closed with error.', Err_Error_String(SSLgeterror(ssl, ssl_error), Nil));

  // Close socket
  CloseSocket(CSocket);

  // Clean up.
  if Assigned(ssl) then
    SslFree(ssl);

  if Assigned(ctx) then
    SSLCtxFree(ctx);
end.


