/*
 * $Id: WinAPIUtils.h 485 2012-06-03 15:17:19Z exodus8 $
 *
 * (C) 2011-2013 see Authors.txt
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

#include <Windows.h>

struct IDirect3D9;

BOOL IsWinXPOrLater();
BOOL IsWinVistaOrLater();
BOOL IsWinSevenOrLater();
BOOL IsWinEight();

BOOL IsCompositionEnabled();

bool SetPrivilege(LPCTSTR privilege, bool bEnable=true);

bool ExportRegistryKey(CStdioFile& file, HKEY hKeyRoot, CString keyName=_T(""));

UINT GetAdapter(IDirect3D9* pD3D, HWND hWnd);

bool IsFontInstalled(LPCTSTR lpszFont);

bool ExploreToFile(CString path);
