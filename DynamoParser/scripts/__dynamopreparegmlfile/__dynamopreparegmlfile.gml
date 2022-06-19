function __DynamoPrepareGMLFile(_name, _relativePath, _absolutePath, _variablePrefix)
{
    if (!file_exists(_absolutePath)) __DynamoError("Could not find \"", _absolutePath, "\"");
    
    var _contentBuffer = buffer_load(_absolutePath);
    var _parserData = __DynamoExtractExpressions(_contentBuffer);
    
    //Don't do anything if there're no Dynamo variables in this GML file
    if (array_length(_parserData) <= 0)
    {
        buffer_delete(_contentBuffer);
        return;
    }
    
    //Otherwise we're gonna get our hands dirty, make a backup
    __DynamoRegisterBackup(_name, _absolutePath);
    var _hash = __DynamoFileHash(_absolutePath);
    
    //Set up a batched buffer operation so we can modify the source GML
    //This handles the annoying offset calculations for us
    var _batchOp = new __DynamoBufferBatch();
    _batchOp.FromBuffer(_contentBuffer);
    
    var _i = 0;
    repeat(array_length(_parserData))
    {
        with(_parserData[_i])
        {
            var _variableIdentifier = _variablePrefix + string(_i);
                
            //Insert the function call to __DynamoVariable() with the variable identifier whilst also commenting out the original expression
            _batchOp.Insert(startPos, "__DynamoExpression(\"", _variableIdentifier, "\") /*");
            _batchOp.Insert(endPos+1, "*/");
                
            //Add the variable identifier and token information to our global handler
            global.__dynamoExpressionDict[$ _variableIdentifier] = innerString;
        }
            
        ++_i;
    }
    
    //Commit the batch operation and return a buffer, then immediately save it out to disk
    buffer_save(_batchOp.GetBuffer(), _absolutePath);
    _batchOp.Destroy();
    
    array_push(global.__dynamoExpressionFileArray, {
        __name: _name,
        __variablePrefix: _variablePrefix,
        __path: _relativePath,
        __hash: _hash,
    });
}