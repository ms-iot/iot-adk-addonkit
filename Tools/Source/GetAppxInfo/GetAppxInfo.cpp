// GetAppxInfo.cpp : Defines the entry point for the console application.
//

#include <iostream>
#include <iomanip>
#include <string>

#include <Windows.h>

#include <wrl\client.h>
#include <wrl\wrappers\corewrappers.h>

#include <AppxPackaging.h>
#include <msopc.h>
#include <experimental\filesystem>

#define RETURN_IF_FAILED(hr) do { HRESULT __hrRet = (hr); if (FAILED(__hrRet)) { return __hrRet; }} while (0, 0)

using namespace std;

using namespace Microsoft::WRL;
using namespace Microsoft::WRL::Wrappers;

const int column1 = 20;

HRESULT PrintPackageIdInternal(const ComPtr<IAppxManifestPackageId>& packageId)
{
    LPWSTR value;

    RETURN_IF_FAILED(packageId->GetName(&value));
    wcout << setw(column1) << left << L"Name" << L" : " << value << endl;
    CoTaskMemFree(value);

    RETURN_IF_FAILED(packageId->GetPublisher(&value));
    wcout << setw(column1) << left << L"Publisher" << L" : " << value << endl;
    CoTaskMemFree(value);

    APPX_PACKAGE_ARCHITECTURE architecture;
    RETURN_IF_FAILED(packageId->GetArchitecture(&architecture));
    switch (architecture)
    {
    case APPX_PACKAGE_ARCHITECTURE_ARM:
        wcout << setw(column1) << left << L"Architecture" << L" : " << L"ARM" << endl;
        break;

        //case APPX_PACKAGE_ARCHITECTURE_ARM64:
        //    wcout << setw(column1) << left << L"Architecture" << L" : " << L"ARM64" << endl;
        //    break;

    case APPX_PACKAGE_ARCHITECTURE_X64:
        wcout << setw(column1) << left << L"Architecture" << L" : " << L"X64" << endl;
        break;

    case APPX_PACKAGE_ARCHITECTURE_X86:
        wcout << setw(column1) << left << L"Architecture" << L" : " << L"X86" << endl;
        break;

    case APPX_PACKAGE_ARCHITECTURE_NEUTRAL:
        wcout << setw(column1) << left << L"Architecture" << L" : " << L"Neutral" << endl;
        break;
    }

    RETURN_IF_FAILED(packageId->GetResourceId(&value));
    wcout << setw(column1) << left << L"ResourceId" << L" : " << (value ? value : L" ") << endl;
    CoTaskMemFree(value);

    UINT64 version;
    RETURN_IF_FAILED(packageId->GetVersion(&version));
    WORD major = static_cast<WORD>((version & 0xFFFF000000000000ui64) >> 48);
    WORD minor = static_cast<WORD>((version & 0x0000FFFF00000000ui64) >> 32);
    WORD build = static_cast<WORD>((version & 0x00000000FFFF0000ui64) >> 16);
    WORD revision = static_cast<WORD>((version & 0x000000000000FFFFui64));
    wcout << setw(column1) << left << L"Version" << L" : " << major << L"." << minor << L"." << build << L"." << revision << endl;

    RETURN_IF_FAILED(packageId->GetPackageFullName(&value));
    wcout << setw(column1) << left << L"PackageFullName" << L" : " << value << endl;
    CoTaskMemFree(value);

    // InstallLocation
    // IsFramework

    RETURN_IF_FAILED(packageId->GetPackageFamilyName(&value));
    wcout << setw(column1) << left << L"PackageFamilyName" << L" : " << value << endl;
    CoTaskMemFree(value);

    return S_OK;
}

HRESULT PrintPackageReaderInternal(const ComPtr<IAppxPackageReader>& packageReader)
{
    HRESULT hr = S_OK;

    ComPtr<IAppxManifestReader> manifestReader;
    ComPtr<IAppxManifestApplication> application;
    ComPtr<IAppxManifestProperties> properties;
    ComPtr<IAppxManifestPackageId> packageId;
    ComPtr<IAppxManifestApplicationsEnumerator> applications;

    RETURN_IF_FAILED(packageReader->GetManifest(&manifestReader));

    // get the manifest info
    RETURN_IF_FAILED(manifestReader->GetProperties(properties.GetAddressOf()));
    RETURN_IF_FAILED(manifestReader->GetPackageId(packageId.GetAddressOf()));
    RETURN_IF_FAILED(manifestReader->GetApplications(applications.GetAddressOf()));
    RETURN_IF_FAILED(applications->GetCurrent(application.GetAddressOf()));

    LPWSTR value;

    RETURN_IF_FAILED(PrintPackageIdInternal(packageId));

    hr = properties->GetStringValue(L"DisplayName", &value);
    if (SUCCEEDED(hr))
    {
        wcout << setw(column1) << left << L"DisplayName" << L" : " << value << endl;
        CoTaskMemFree(value);
    }

    hr = properties->GetStringValue(L"PublisherDisplayName", &value);
    if (SUCCEEDED(hr))
    {
        wcout << setw(column1) << left << L"PublisherDisplayName" << L" : " << value << endl;
        CoTaskMemFree(value);
    }

    hr = properties->GetStringValue(L"Logo", &value);
    if (SUCCEEDED(hr))
    {
        wcout << setw(column1) << left << L"Logo" << L" : " << value << endl;
        CoTaskMemFree(value);
    }

    RETURN_IF_FAILED(application->GetAppUserModelId(&value));
    wcout << setw(column1) << left << L"AppUserModelId" << L" : " << value << endl;
    CoTaskMemFree(value);

    // Capabilities?
    // DeviceCapabilities?
    // PackageDependencies?
    // Prerequisites? (OSMinVersion, OSMaxVersionTested)

    return S_OK;

}

HRESULT GetPackageIdFromAppxBundleInternal(const std::wstring& packagePath)
{
    if (packagePath.length() == 0)
    {
        return E_INVALIDARG;
    }

    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
    if (FAILED(hr))
    {
        wcout << L"CoInitializeEx failed" << endl;
        return hr;
    }

    Microsoft::WRL::ComPtr<IAppxBundleFactory> appxBundleFactory;
    Microsoft::WRL::ComPtr<IOpcFactory> opcFactory;
    Microsoft::WRL::ComPtr<IStream> bundleStream;
    Microsoft::WRL::ComPtr<IAppxBundleReader> bundleReader;
    Microsoft::WRL::ComPtr<IAppxBundleManifestReader> bundleManifestReader;
    ComPtr<IAppxManifestProperties> properties;
    ComPtr<IAppxManifestPackageId> packageId;
    ComPtr<IAppxManifestApplicationsEnumerator> applications;
    ComPtr<IAppxBundleManifestPackageInfo> packageInfo;
    ComPtr<IAppxBundleManifestPackageInfoEnumerator> packageInfoItems;

    RETURN_IF_FAILED(CoCreateInstance(__uuidof(AppxBundleFactory), NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(appxBundleFactory.GetAddressOf())));
    RETURN_IF_FAILED(CoCreateInstance(__uuidof(OpcFactory), NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(opcFactory.GetAddressOf())));
#pragma warning(suppress: 25086) // Use default security descriptor.
    RETURN_IF_FAILED(opcFactory->CreateStreamOnFile(packagePath.c_str(), OPC_STREAM_IO_READ, NULL, FILE_ATTRIBUTE_NORMAL, &bundleStream));
    RETURN_IF_FAILED(appxBundleFactory->CreateBundleReader(bundleStream.Get(), &bundleReader));
    RETURN_IF_FAILED(bundleReader->GetManifest(&bundleManifestReader));
    
    // get the manifest info
    RETURN_IF_FAILED(bundleManifestReader->GetPackageId(packageId.GetAddressOf()));
    RETURN_IF_FAILED(bundleManifestReader->GetPackageInfoItems(&packageInfoItems));

    BOOL hasCurrent = FALSE;
    RETURN_IF_FAILED(packageInfoItems->GetHasCurrent(&hasCurrent));
    
    while (hasCurrent)
    {
        ComPtr<IAppxBundleManifestPackageInfo> currentPackageInfo;
        RETURN_IF_FAILED(packageInfoItems->GetCurrent(&currentPackageInfo));

        APPX_BUNDLE_PAYLOAD_PACKAGE_TYPE packageType;
        RETURN_IF_FAILED(currentPackageInfo->GetPackageType(&packageType));

        LPWSTR fileName;
        RETURN_IF_FAILED(currentPackageInfo->GetFileName(&fileName));
        wcout << setw(column1) << left << L"File Name" << L" : " << fileName << endl;

        switch (packageType)
        {
            case APPX_BUNDLE_PAYLOAD_PACKAGE_TYPE_APPLICATION:
            {
                ComPtr<IAppxFile> applicationPackageFile;
                ComPtr<IStream> applicationPackageStream;
                ComPtr<IAppxFactory> appxFactory;
                ComPtr<IAppxPackageReader> packageReader;

                wcout << setw(column1) << left << L"Package Type" << L" : " << L"application" << endl;
                RETURN_IF_FAILED(bundleReader->GetPayloadPackage(fileName, &applicationPackageFile));
                RETURN_IF_FAILED(applicationPackageFile->GetStream(&applicationPackageStream));
                RETURN_IF_FAILED(CoCreateInstance(__uuidof(AppxFactory), NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(appxFactory.GetAddressOf())));
                RETURN_IF_FAILED(appxFactory->CreatePackageReader(applicationPackageStream.Get(), &packageReader));
                RETURN_IF_FAILED(PrintPackageReaderInternal(packageReader));
            }
            break;

            case APPX_BUNDLE_PAYLOAD_PACKAGE_TYPE_RESOURCE:
                wcout << setw(column1) << left << L"Package Type" << L" : " << L"resource" << endl;
                break;
        }

        ComPtr<IAppxManifestPackageId> packageId;
        RETURN_IF_FAILED(currentPackageInfo->GetPackageId(&packageId));
        RETURN_IF_FAILED(PrintPackageIdInternal(packageId));

        //RETURN_IF_FAILED(bundleManifestReader->GetApplications(applications.GetAddressOf()));
        //GetProperties(properties.GetAddressOf()));

        wcout << endl;
        RETURN_IF_FAILED(packageInfoItems->MoveNext(&hasCurrent));
    }

    return S_OK;
}

HRESULT GetPackageIdFromAppxInternal(const wstring& packagePath)
{
    if (packagePath.length() == 0)
    {
        return E_INVALIDARG;
    }

    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
    if (FAILED(hr))
    {
        wcout << L"CoInitializeEx failed" << endl;
        return hr;
    }

    ComPtr<IAppxFactory> appxFactory;
    ComPtr<IOpcFactory> opcFactory;
    ComPtr<IStream> packageStream;
    ComPtr<IAppxPackageReader> packageReader;

    // read the manifest
    RETURN_IF_FAILED(CoCreateInstance(__uuidof(AppxFactory), NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(appxFactory.GetAddressOf())));
    RETURN_IF_FAILED(CoCreateInstance(__uuidof(OpcFactory), NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(opcFactory.GetAddressOf())));
    RETURN_IF_FAILED(opcFactory->CreateStreamOnFile(packagePath.c_str(), OPC_STREAM_IO_READ, NULL, FILE_ATTRIBUTE_NORMAL, &packageStream));
    RETURN_IF_FAILED(appxFactory->CreatePackageReader(packageStream.Get(), &packageReader));
    RETURN_IF_FAILED(PrintPackageReaderInternal(packageReader));

    return S_OK;
}

int wmain(int argc, wchar_t *argv[])
{
    if (argc < 2)
    {
        wcout << "GetAppxInfo <path to appx file>" << endl;
        return -1;
    }

    std::wstring packagePath(argv[1]);
    std::experimental::filesystem::path appxPath(packagePath);
    std::wstring fileExtension = appxPath.extension();
    transform(fileExtension.begin(), fileExtension.end(), fileExtension.begin(), ::towlower);

    HRESULT hr = S_OK;
    if (fileExtension == L".appx")
    {
        hr = GetPackageIdFromAppxInternal(argv[1]);
    }
    else if (fileExtension == L".appxbundle")
    {
        hr = GetPackageIdFromAppxBundleInternal(argv[1]);
    }

    if (FAILED(hr))
    {
        wcout << L"ERROR: " << std::hex << hr << endl;
        return hr;
    }
    return 0;
}

