// CodeHookTest.cpp : Defines the entry point for the application.
//

#include <windows.h>
#include "..\..\Include\cpp\codehook.h"

ICodeHook * codehook;
ICodeHookHelper *helper;

void ShowMsg(const char *msg)
{
	MessageBox(0, msg, "Test", MB_OK);
}

class TestClass
{
public:
	TestClass() {
		TestValue = 99;
	}
	int __cdecl TestHook(TCodeHookHandle handle, PUINT params)
	{
		char buf[1024];
		char *msg = (char *)(params[0]);
		int value = params[1];
		int r = codehook->CallPreviousMethod(handle, params);
		
		wsprintf(buf, "Object hook: %s %d %d", msg, value, r);
		
		ShowMsg(buf);
		
		return 0;
	}

	int __stdcall TestTarget(const char *msg, int value)
	{
		char buf[1024];
		
		wsprintf(buf, "Object target: %s %d %d", msg, value, TestValue);
		
		ShowMsg(buf);
		
		return value * 2;
	}
private:
	int TestValue;
};


int __cdecl TestHook(TCodeHookHandle handle, PUINT params)
{
	char buf[1024];
	char *msg = (char *)(params[0]);
	int value = params[1];
	int r = codehook->CallPreviousMethod(handle, params);
	
	wsprintf(buf, "Hook: %s %d %d", msg, value, r);
	
	ShowMsg(buf);

	return 0;
}

int __stdcall TestTarget(const char *msg, int value)
{
	char buf[1024];

	wsprintf(buf, "Target: %s %d", msg, value);

	ShowMsg(buf);

	return value * 2;
}

void DoTest()
{
#ifdef CHOOK_DYNAMIC_DLL
	CodeHookDynamicLoader::InitLoader("..\\..\\..\\CHook.dll");
#endif
	GetCodeHook((void **)&codehook);
	if(!codehook) {
		char buf[1024];
		wsprintf(buf, "Can't load dll %s", CodeHookDllName);
		ShowMsg(buf);
		return;
	}

	codehook->GetCodeHookHelper(&helper);

	helper->SetCallingConvention(HCC_STDCALL, HCC_CDECL);
	helper->HookWithGlobalMethod(NULL, TestTarget, TestHook, 2, 0);
	TestTarget("Test only", 3);

	TestClass tc;

	helper->SetCallingConvention(HCC_STDCALL, HCC_CDECL);
	int (__stdcall TestClass::* func1)(const char *,int) = TestClass::TestTarget;
	int (__cdecl TestClass::* func2)(TCodeHookHandle handle, PUINT params) = TestClass::TestHook;
	helper->HookWithObjectMethod(&tc, &tc, *((Pointer *)&func1), *((Pointer *)&func2), 2, 0);

	tc.TestTarget("Test in class only", 5);
}

int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	DoTest();
	return 0;
}
