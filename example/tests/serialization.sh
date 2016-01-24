#!/usr/bin/env bash

source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/../lib/oo-bootstrap.sh"

import lib/type-core
import lib/types/base
import lib/types/ui
import lib/types/util/test

class:NestedTestObject() {
    extends Object

    public String aNestedString = "nestedString"
    public Array aNestedArray
    private String _nonSerialized = "do not serialize me either"

    NestedTestObject::Feature() {
        $this._nonSerialized
        $this._nonSerialized = "new value"
    }
}

Type.Load

class:TestObject() {
    extends Object
    
    public Number aNumber = 512
    public String aString = "some string here"
    public NestedTestObject aNestedObject
    private String _nonSerialized = "do not serialize me"

    TestObject::__constructor__() {
        $this.aNestedObject.aNestedArray.Add "first element"
        $this.aNestedObject.aNestedArray.Add "second element"
    }

    TestObject::Feature() {
        $this._nonSerialized
        $this._nonSerialized = "new value"
    }
}

Type.Load


## TESTS ##

(
    Test.NewGroup "Serialization"

    ## prepare object for unit tests:
    TestObject object

    it 'should serialize an object'
    try
        object.Serialize | jq .
    expectOutputPass

    Test.DisplaySummary


    Test.NewGroup "Type System"

    it 'should not allow accessing private properties'
    try
        object._nonSerialized
    expectFail

    it 'should not allow accessing private properties of child objects'
    try
        object.aNestedObject._nonSerialized
    expectFail

    it 'should allow accessing of private properties from functions within the object'
    try
        object.Feature
        object.Feature
        object.aNestedObject.Feature
        object.aNestedObject.Feature
    expectOutputPass

    Test.DisplaySummary
)