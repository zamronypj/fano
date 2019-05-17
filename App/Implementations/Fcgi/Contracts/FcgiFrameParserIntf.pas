{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiFrameParserIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiRecordIntf;

type

    (*!-----------------------------------------------
     * Interface for any class having capability to parse
     * FastCGI Frame
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IFcgiFrameParser = interface
        ['{06B79D63-55E3-4B6E-BFD9-65CE6ED72636}']

        (*!------------------------------------------------
        * test if buffer contain FastCGI frame package
        * i.e FastCGI header + payload
        *-----------------------------------------------
        * @param buffer, pointer to current buffer
        * @return true if buffer contain valid frame
        *-----------------------------------------------*)
        function hasFrame(const buffer : pointer;  const bufferSize : int64) : boolean;

        (*!------------------------------------------------
         * parse current buffer and create its corresponding
         * FastCGI record instance
         *-----------------------------------------------
         * @param buffer, pointer to current buffer
         * @param bufferSize, size of buffer
         * @return IFcgiRecord instance
         * @throws EInvalidFcgiBuffer exception when buffer is nil
         * @throws EInvalidFcgiHeaderLen exception when header size not valid
         *-----------------------------------------------*)
        function parseFrame(const buffer : pointer;  const bufferSize : int64) : IFcgiRecord;
    end;

implementation

end.
