package ca.on.oicr.capsid

import grails.test.mixin.TestFor

@TestFor(BrowseController)
class BrowseControllerTests {

    void testIndex() {
        controller.index()
        assert "/browse/show" == response.redirectedUrl
    }
}
