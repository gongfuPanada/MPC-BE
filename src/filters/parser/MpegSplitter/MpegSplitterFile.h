/*
 * $Id$
 *
 * (C) 2003-2006 Gabest
 * (C) 2006-2013 see Authors.txt
 *
 * This file is part of MPC-BE.
 *
 * MPC-BE is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * MPC-BE is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#pragma once

#include <atlbase.h>
#include <atlcoll.h>
#include "../BaseSplitter/BaseSplitter.h"
#include "../../../DSUtil/GolombBuffer.h"

#define NO_SUBTITLE_PID		1 // Fake PID use for the "No subtitle" entry
#define NO_SUBTITLE_NAME	_T("No subtitle")

#define ISVALIDPID(pid)		(pid >= 0x10 && pid < 0x1fff)

#define MVC_SUPPORT			0 // set 1 to enable MVC splitting support

class CMpegSplitterFile : public CBaseSplitterFileEx
{
	CAtlMap<WORD, BYTE> m_pid2pes;
	CAtlMap<WORD, CMpegSplitterFile::avchdr> avch;
	bool m_bIsHdmv;
	bool m_init;

	HRESULT Init(IAsyncReader* pAsyncReader);

	void OnComplete(IAsyncReader* pAsyncReader);

public:
	CHdmvClipInfo &m_ClipInfo;
	CMpegSplitterFile(IAsyncReader* pAsyncReader, HRESULT& hr, bool bIsHdmv, CHdmvClipInfo &ClipInfo, bool ForcedSub, int AC3CoreOnly, bool m_AlternativeDuration, bool SubEmptyPin);

	REFERENCE_TIME NextPTS(DWORD TrackNum);

	CCritSec m_csProps;

	MPEG_TYPES m_type;

	REFERENCE_TIME m_rtMin, m_rtMax;
	__int64 m_posMin, m_posMax;
	int m_rate; // byte/sec

	int m_AC3CoreOnly;
	bool m_ForcedSub, m_AlternativeDuration, m_SubEmptyPin;

	struct stream {
		CMpegSplitterFile *m_pFile;
		CMediaType mt;
		WORD pid;
		BYTE pesid, ps1id;
		char lang[4];
		bool lang_set;

		struct stream() {
			memset(this, 0, sizeof(*this));
		}
		operator DWORD() const {
			return pid ? pid : ((pesid<<8)|ps1id);
		}
		bool operator == (const struct stream& s) const {
			return (DWORD)*this == (DWORD)s;
		}
	};

	enum {video, audio, subpic,
#if MVC_SUPPORT
		  stereo,
#endif
		  unknown
		 };

	class CStreamList : public CAtlList<stream>
	{
	public:
		void Insert(stream& s, CMpegSplitterFile *_pFile, int type) {
			if (type == subpic) {
				if (s.pid == NO_SUBTITLE_PID) {
					AddTail(s);
					return;
				}
				for (POSITION pos = GetHeadPosition(); pos; GetNext(pos)) {
					stream& s2 = GetAt(pos);
					if (s.pid < s2.pid || s2.pid == NO_SUBTITLE_PID) {
						InsertBefore(pos, s);
						return;
					}
				}
				AddTail(s);
			} else {
				Insert(s, _pFile);
			}
		}

		void Insert(stream& s, CMpegSplitterFile *_pFile) {
			s.m_pFile = _pFile;
			AddTail(s);
			if (GetCount() > 1) {
				for (size_t j=0; j<GetCount(); j++) {
					for (size_t i=0; i<GetCount()-1; i++) {
						if (GetAt(FindIndex(i)) > GetAt(FindIndex(i+1))) {
							SwapElements(FindIndex(i), FindIndex(i+1));
						}
					}
				}
			}
		}

		void Replace(stream& source, stream& dest, CMpegSplitterFile *_pFile) {
			source.m_pFile = _pFile;
			dest.m_pFile = _pFile;
			for (POSITION pos = GetHeadPosition(); pos; GetNext(pos)) {
				stream& s = GetAt(pos);
				if (source == s) {
					SetAt(pos, dest);
					return;
				}
			}
		}

		static CStringW ToString(int type) {
			return
				type == video	? L"Video" :
				type == audio	? L"Audio" :
				type == subpic	? L"Subtitle" :
#if MVC_SUPPORT
				type == stereo	? L"Stereo" :
#endif
				L"Unknown";
		}

		const stream* FindStream(int pid) {
			for (POSITION pos = GetHeadPosition(); pos; GetNext(pos)) {
				const stream& s = GetAt(pos);
				if (s.pid == pid) {
					return &s;
				}
			}

			return NULL;
		}

	} m_streams[unknown];

	void SearchStreams(__int64 start, __int64 stop, IAsyncReader* pAsyncReader, BOOL CalcDuration = FALSE);
	DWORD AddStream(WORD pid, BYTE pesid, BYTE ps1id, DWORD len);
	void  AddHdmvPGStream(WORD pid, const char* language_code);
	CAtlList<stream>* GetMasterStream();
	bool IsHdmv() {
		return m_bIsHdmv;
	};

	struct program {
		WORD program_number;
		struct stream {
			WORD			pid;
			PES_STREAM_TYPE	type;

		};
		stream streams[64];

		BYTE ts_buffer[1024];
		WORD ts_len_cur, ts_len_packet;

		struct program() {
			memset(this, 0, sizeof(*this));
		}
	};

	CAtlMap<WORD, program> m_programs;

	void SearchPrograms(__int64 start, __int64 stop);
	void UpdatePrograms(const trhdr& h, bool UpdateLang = true);
	void UpdatePrograms(CGolombBuffer gb, WORD pid, bool UpdateLang = true);
	const program* FindProgram(WORD pid, int &iStream, const CHdmvClipInfo::Stream * &_pClipInfo);

	CAtlMap<DWORD, CStringA> m_pPMT_Lang;

	bool GetStreamType(WORD pid, PES_STREAM_TYPE &stream_type);
};
