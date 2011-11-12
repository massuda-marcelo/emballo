//************************************************************************
//Win32 CodeHook 1.0.0
//http://www.kbasm.com/
//
//The contents of this file are subject to the Mozilla Public License
//Version 1.1 (the "License"); you may not use this file except in
//compliance with the License.
//You may obtain a copy of the License at http://www.mozilla.org/MPL/
//
//Software distributed under the License is distributed on an "AS IS" basis,
//WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
//for the specific language governing rights and limitations under the
//License.
//
//The Original Code is CodeHook.h
//
//The Initial Developer of the Original Code is Wang Qi.
//************************************************************************


#ifndef __CODEHOOK_H
#define __CODEHOOK_H

#include <windows.h>
#include <unknwn.h>

#ifdef CHOOK_DYNAMIC_DLL

#undef CHOOK_STATIC_DLL
#undef CHOOK_STATIC_LIB

#else //CHOOK_DYNAMIC_DLL

#ifdef CHOOK_STATIC_DLL

#undef CHOOK_DYNAMIC_DLL
#undef CHOOK_STATIC_LIB

#else //CHOOK_STATIC_DLL

#ifdef CHOOK_STATIC_LIB

#undef CHOOK_DYNAMIC_DLL
#undef CHOOK_STATIC_DLL

#else //CHOOK_STATIC_LIB

#define CHOOK_DYNAMIC_DLL

#endif //CHOOK_STATIC_LIB

#endif //CHOOK_STATIC_DLL

#endif //CHOOK_DYNAMIC_DLL


const char *CodeHookDllName = "CHook.dll";

typedef void * TCodeHookHandle;
typedef unsigned int UINT;
typedef UINT * PUINT;
typedef void * Pointer;
typedef unsigned char byte;

const int MAX_EXTRA_PARAM_COUNT = 32;
const TCodeHookHandle INVALID_CODEHOOK_HANDLE = TCodeHookHandle(0);

//Hook Calling Convention
const int HCC_REGISTER = 0; //used in Delphi
const int HCC_STDCALL = 1;
const int HCC_CDECL = 2;

//Hook Error Code
const int HEC_NONE = 0;
const int HEC_FUNCTION_TOO_SMALL = 1;
const int HEC_UNKNOWN_INSTRUCTION = 2;
const int HEC_ADDRESS_CANNOT_WRITE = 3;
const int HEC_INVALID_HANDLE = 4;
const int HEC_INVALID_CC = 5;
const int HEC_TOO_MANY_EXTRA_PARAMS = 6;
const int HEC_EXTEND_INFO_UNAVAILABLE = 7;


#define calltype WINAPI

class ICodeHookError: public IUnknown {
public:
	virtual UINT calltype GetErrorCode() = 0;
	virtual int calltype GetErrorMessage(char * Message, int MessageLen) = 0;
};

class IDirectCodeHook: public ICodeHookError {
public:
	virtual BOOL calltype Hook(Pointer Target, Pointer Hook, Pointer OldFunc) = 0;
	virtual BOOL calltype Unhook(Pointer Target, Pointer AOldFunc) = 0;
	virtual void * calltype AllocatePreviousMethodMemory() = 0;
	virtual void FreePreviousMethodMemory(Pointer OldFunc) = 0;
};

struct TCodeHookInfo {
	Pointer Target;
	Pointer Hook;
	Pointer PreviousMethod;
	Pointer UserData;

	int ExtendInfoAvailable;
	Pointer TargetObject;
	int ParamCount;
	int TargetCallingConvention;
	int HookCallingConvention;
};
typedef TCodeHookInfo * PCodeHookInfo;

class ICodeHookHelper;

class ICodeHook: public ICodeHookError {
public:
	virtual void calltype GetDirectCodeHook(IDirectCodeHook **) = 0;
	virtual void calltype GetCodeHookHelper(ICodeHookHelper **) = 0;
    virtual void calltype CreateCodeHook(ICodeHook **) = 0;

	virtual void calltype SetUserDataSize(int Size) = 0;
	
	virtual TCodeHookHandle calltype Hook(Pointer Target, Pointer Hook) = 0;
	virtual BOOL calltype Unhook(TCodeHookHandle Handle) = 0;

	virtual BOOL calltype GetHookInfo(TCodeHookHandle Handle, PCodeHookInfo Info) = 0;
	virtual Pointer calltype GetUserData(TCodeHookHandle Handle) = 0;
	
	virtual TCodeHookHandle calltype AdvancedHook(Pointer TargetObject,
		Pointer Target, int TargetCallingConvention,
		Pointer Hook, int HookCallingConvention,
		int ParamCount,
		PUINT ExtraParams, int ExtraParamCount,
		UINT Flags) = 0;
	virtual BOOL calltype AdvancedUnhook(TCodeHookHandle Handle) = 0;

	virtual TCodeHookHandle calltype FindHookHandleFromTarget(Pointer Target) = 0;
	virtual UINT calltype CallPreviousMethod(TCodeHookHandle Handle, PUINT Params) = 0;
	virtual UINT calltype CallMethod(Pointer Object, Pointer Method,
		PUINT Params, int ParamCount, int CallingConvention) = 0;
};

class ICodeHookHelper: public ICodeHookError {
public:
	virtual void calltype SetCallingConvention(int TargetCC, int HookCC) = 0;

	virtual TCodeHookHandle calltype HookWithGlobalMethod(Pointer TargetObject, Pointer Target,
		Pointer Hook, int ParamCount, UINT Flags) = 0;
	virtual TCodeHookHandle calltype HookWithObjectMethod(Pointer TargetObject, Pointer AObject,
		Pointer Target, Pointer Hook, int ParamCount, UINT Flags) = 0;
	virtual TCodeHookHandle calltype HookWithGlobalMethodExtra(Pointer SelfPointer, Pointer Target,
		Pointer Hook, int ParamCount,
		PUINT ExtraParams, int ExtraParamCount,
		UINT Flags) = 0;
	virtual TCodeHookHandle calltype HookWithObjectMethodExtra(Pointer SelfPointer, Pointer AObject,
		Pointer Target, Pointer Hook, int ParamCount,
		PUINT ExtraParams, int ExtraParamCount,
		UINT Flags) = 0;
	
	virtual BOOL calltype UnhookTarget(Pointer Target) = 0;
	virtual void calltype UnhookAll() = 0;
};

#ifdef CHOOK_DYNAMIC_DLL

typedef void (calltype *ProcGetCodeHook)(ICodeHook **);

class CodeHookDynamicLoader {
private:
	CodeHookDynamicLoader(const char * dllname) {
		AddrGetCodeHook = NULL;
		char *dll = (char *)dllname;
		if(!dll)
			dll = (char *)CodeHookDllName;
		DllHandle = LoadLibrary(dll);
		if(DllHandle) {
			AddrGetCodeHook = (ProcGetCodeHook)GetProcAddress(DllHandle, "GetCodeHook");
		}
	}
	~CodeHookDynamicLoader() {
		if(DllHandle) {
			FreeLibrary(DllHandle);
			DllHandle = NULL;
		}
	}
	HMODULE DllHandle;
	ProcGetCodeHook AddrGetCodeHook;
public:
	static CodeHookDynamicLoader * Loader;
	static void InitLoader(const char *dllname) {
		if(!Loader) {
			Loader = new CodeHookDynamicLoader(dllname);
		}
	}

	ICodeHook * GetCodeHook() {
		InitLoader(NULL);
		
		ICodeHook * r = NULL;
		if(AddrGetCodeHook)
			AddrGetCodeHook(&r);
		if(r)
			r->AddRef();
		return r;
	}
};

CodeHookDynamicLoader * CodeHookDynamicLoader::Loader = NULL;

void calltype GetCodeHook(void **hook) {
	*hook = CodeHookDynamicLoader::Loader->GetCodeHook();
}
#else

void calltype GetCodeHook(void **hook);

#endif

#endif
