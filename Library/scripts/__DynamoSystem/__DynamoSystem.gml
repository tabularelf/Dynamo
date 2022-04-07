//Not exposed yet but will be eventually
#macro DYNAMO_COMPRESS  false

#macro __DYNAMO_VERSION    "0.1.0"
#macro __DYNAMO_DATE       "2022-04-07"
#macro __DYNAMO_DEV_MODE   (DYNAMO_DEV_MODE && global.__dynamoRunningFromIDE)

__DynamoTrace("Welcome to Dynamo by @jujuadams! This is version ", __DYNAMO_VERSION, ", ", __DYNAMO_DATE);



/*
Icon "${ICON_FILE}"
RequestExecutionLevel user
OutFile "${INSTALLER_FILENAME}"
SilentInstall silent
Section "${PRODUCT_NAME}"
    SetOutPath `$TEMP\${PRODUCT_NAME}`
    File /r "${SOURCE_DIR}\*.*"
    ExecWait `$TEMP\${PRODUCT_NAME}\${EXE_NAME}.exe "$CMDLINE"`
    RMDir /r `$TEMP\${PRODUCT_NAME}`
SectionEnd
*/



__DynamoInit();

if (DYNAMO_LOAD_MANIFEST_ON_BOOT)
{
    __DynamoTrace("Loading manifest on boot");
    __DynamoEnsureManifest();
}



function __DynamoInit()
{
    if (variable_global_exists("__dynamoInFocus")) return;
    
    global.__dynamoInFocus = true;
    
    global.__dynamoNoteDictionaryBuilt = false;
    global.__dynamoNoteDictionary = {};
    
    global.__dynamoFileDictionary = {};
    
    global.__dynamoProjectDirectory = undefined;
    global.__dynamoWorkingDirectory = undefined;
    
    
    
    global.__dynamoRunningFromIDE = false;
    
    if (code_is_compiled() && (parameter_count() == 1))
    {
        var _path = filename_dir(parameter_string(0));
        
        var _last_folder = _path;
        do
        {
            var _pos = string_pos("\\", _last_folder);
            if (_pos > 0) _last_folder = string_delete(_last_folder, 1, _pos);
        }
        until (_pos <= 0);
        
        var _last_four = string_copy(_last_folder, string_length(_last_folder) - 3, 4);
        var _filename = filename_change_ext(filename_name(parameter_string(0)), "");
        
        if ((_last_four == "_YYC")
        &&  (string_length(_last_folder) - string_length(_filename) == 13))
        {
            global.__dynamoRunningFromIDE = true;
        }
    }
    else
    {
        if ((parameter_count() == 3)
        &&  (filename_name(parameter_string(0)) == "Runner.exe")
        &&  (parameter_string(1) == "-game")
        &&  (filename_ext(parameter_string(2)) == ".win"))
        {
            global.__dynamoRunningFromIDE = true;
        }
    }
    
    
    
    if (__DYNAMO_DEV_MODE)
    {
        __DynamoEnsureProjectDirectory();
        
        global.__dynamoWorkingDirectory = global.__dynamoProjectDirectory + "datafilesDynamo\\linkToWorkingDirectory.dynamo\\";
        __DynamoTrace("Working directory = \"", global.__dynamoWorkingDirectory, "\"");
        
        global.__dynamoFileDictionary = __DynamoRecursiveFileSearch(global.__dynamoProjectDirectory + "datafilesDynamo\\", {});
    }
}



function __DynamoTrace()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_debug_message("Dynamo: " + _string);
}

function __DynamoError()
{
    var _string = "";
    var _i = 0;
    repeat(argument_count)
    {
        _string += string(argument[_i]);
        ++_i;
    }
    
    show_error("Dynamo:\n\n" + _string + "\n ", true);
}

function __DynamoBufferSave(_buffer, _filename, _tell = buffer_get_size(_buffer))
{
    if (DYNAMO_COMPRESS)
    {
        var _compressedBuffer = buffer_compress(_buffer, 0, _tell);
        buffer_save(_compressedBuffer, _filename);
        buffer_delete(_compressedBuffer);
    }
    else
    {
        buffer_save(_buffer, _filename);
    }
}

function __DynamoNameHash(_name)
{
    return md5_string_utf8(_name);
}
