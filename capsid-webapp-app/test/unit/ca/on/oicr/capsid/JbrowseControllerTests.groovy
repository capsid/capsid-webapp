package ca.on.oicr.capsid

import grails.test.mixin.TestFor

@TestFor(JbrowseController)
class JbrowseControllerTests {

    void testIndex() {
        controller.index()
        assert "/jbrowse/show" == response.redirectedUrl
    }
}
