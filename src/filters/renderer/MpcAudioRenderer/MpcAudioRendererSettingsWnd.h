/*
 * $Id$
 *
 * (C) 2010-2013 see Authors.txt
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

#include "../../filters/InternalPropertyPage.h"
#include "IMpcAudioRenderer.h"
#include "resource.h"
#include <afxcmn.h>

class __declspec(uuid("1E53BA32-3BCC-4dff-9342-34E46BE3F5A5"))
	CMpcAudioRendererSettingsWnd : public CInternalPropertyPageWnd
{
private :
	CComQIPtr<IMpcAudioRendererFilter> m_pMAR;

	CStatic   m_txtWasapiMode;
	CComboBox m_cbWasapiMode;

	CButton   m_cbMuteFastForward;

	CStatic   m_txtSoundDevice;
	CComboBox m_cbSoundDevice;

	CStatic   m_txtModeText;

	enum {
		IDC_PP_WASAPI_MODE = 10000,
		IDC_PP_MUTE_FAST_FORWARD,
		IDC_PP_SOUND_DEVICE,
		IDC_PP_WASAPI_MODE_STATUS
	};

public:
	CMpcAudioRendererSettingsWnd(void);


	bool OnConnect(const CInterfaceList<IUnknown, &IID_IUnknown>& pUnks);
	void OnDisconnect();
	bool OnActivate();
	void OnDeactivate();
	bool OnApply();

	HRESULT GetAvailableAudioDevices();

	static LPCTSTR GetWindowTitle() { return MAKEINTRESOURCE(IDS_FILTER_SETTINGS_CAPTION); }
	static CSize GetWindowSize() { return CSize(340, 160); }

	DECLARE_MESSAGE_MAP()
};
