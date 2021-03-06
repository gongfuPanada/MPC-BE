/*
 * $Id$
 *
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

#include "../../filters/InternalPropertyPage.h"
#include "IMPCVideoDec.h"
#include "resource.h"
#include <afxcmn.h>

// === New swscaler options
#include "Version.h"
//

enum {
	IDC_PP_THREAD_NUMBER = 10000,
	IDC_PP_DISCARD_MODE,
	IDC_PP_ERROR_RECOGNITION,
	IDC_PP_IDCTALGO,
	IDC_PP_AR,
	IDC_PP_DXVA_CHECK,
	IDC_PP_DXVA_SD,
	IDC_PP_SWOUTPUTFORMATUP,
	IDC_PP_SWOUTPUTFORMATDOWN,
	IDC_PP_SWCHROMATORGB,
	IDC_PP_RESIZEMETHODBE,
	IDC_PP_SWCOLORSPACE,
	IDC_PP_SWINPUTLEVELS,
	IDC_PP_SWOUTPUTLEVELS,
	IDC_PP_DEINTERLACING
};

class __declspec(uuid("D5AA0389-D274-48e1-BF50-ACB05A56DDE0"))
	CMPCVideoDecSettingsWnd : public CInternalPropertyPageWnd
{
	CComQIPtr<IMPCVideoDecFilter> m_pMDF;

	CFont		m_arrowsFont;

	CButton		m_grpFFMpeg;
	CStatic		m_txtThreadNumber;
	CComboBox	m_cbThreadNumber;
	CStatic		m_txtDiscardMode;
	CComboBox	m_cbDiscardMode;
	CStatic		m_txtDeinterlacing;
	CComboBox	m_cbDeinterlacing;

	CButton		m_grpDXVA;
	CStatic		m_txtDXVAMode;
	CEdit		m_edtDXVAMode;
	CStatic		m_txtVideoCardDescription;
	CEdit		m_edtVideoCardDescription;

	CButton		m_cbARMode;

	CStatic		m_txtDXVACompatibilityCheck;
	CComboBox	m_cbDXVACompatibilityCheck;

	CButton		m_cbDXVA_SD;

	// === New swscaler options
	CStatic			m_txtSwOutputFormats;
	CCheckListBox	m_lstSwOutputFormats;
	CImageList		m_onoff;
	CButton			m_cbSwOutputFormatUp;
	CButton			m_cbSwOutputFormatDown;

	int			m_nSwIndex[6];
	int			m_nSwChecked[6];

	CStatic     m_txtSwChromaToRGB;
	CComboBox   m_cbSwChromaToRGB;

	CStatic     m_txtSwResizeMethodBE;
	CComboBox   m_cbSwResizeMethodBE;

	CStatic     m_txtSwColorspace;
	CComboBox   m_cbSwColorspace;

	CStatic     m_txtSwInputLevels;
	CComboBox   m_cbSwInputLevels;

	CStatic     m_txtSwOutputLevels;
	CComboBox   m_cbSwOutputLevels;

	CStatic     m_txtSwVersion;
	CString     m_strSwVersion;

public:
	CMPCVideoDecSettingsWnd();

	bool OnConnect(const CInterfaceList<IUnknown, &IID_IUnknown>& pUnks);
	void OnDisconnect();
	bool OnActivate();
	void OnDeactivate();
	bool OnApply();

	static LPCTSTR GetWindowTitle() { return MAKEINTRESOURCE(IDS_FILTER_SETTINGS_CAPTION); }
	static CSize GetWindowSize() { return CSize(453, 356); }

	DECLARE_MESSAGE_MAP()

	// === New swscaler options
	afx_msg void OnClickedSwOutputFormatUp();
	afx_msg void OnClickedSwOutputFormatDown();

	afx_msg BOOL OnToolTipNotify(UINT id, NMHDR * pNMHDR, LRESULT * pResult);
	//

};

class __declspec(uuid("3C395D46-8B0F-440d-B962-2F4A97355453"))
	CMPCVideoDecCodecWnd : public CInternalPropertyPageWnd
{
	CComQIPtr<IMPCVideoDecFilter> m_pMDF;

	CButton			m_grpSelectedCodec;
	CCheckListBox	m_lstCodecs;
	CImageList		m_onoff;

public:
	CMPCVideoDecCodecWnd();

	bool OnConnect(const CInterfaceList<IUnknown, &IID_IUnknown>& pUnks);
	void OnDisconnect();
	bool OnActivate();
	void OnDeactivate();
	bool OnApply();

	static LPCTSTR GetWindowTitle() { return _T("Codecs");    }
	static CSize GetWindowSize()    { return CSize(453, 356); }

	DECLARE_MESSAGE_MAP()
};
