package ca.on.oicr.capsid

import grails.test.mixin.TestFor
import grails.test.mixin.Mock

@TestFor(AlignmentController)
@Mock(Alignment)
class AlignmentControllerTests {


//    def populateValidParams(params) {
//      assert params != null
//      // TODO: Populate valid properties like...
//      //params["name"] = 'someValidName'
//    }

    void testIndex() {
        controller.index()
        assert "/alignment/list" == response.redirectedUrl
    }

//    void testList() {
//
//        def control = mockFor(AlignmentService)
//        control.demand.list(0) { Map params -> [] }
//        controller.alignmentService = control.createMock()
//
//        def model = controller.list()
//
//        assert model.alignmentInstanceList.size() == 0
//        assert model.alignmentInstanceTotal == 0
//    }
//
//    void testCreate() {
//       def model = controller.create()
//
//       assert model.alignmentInstance != null
//    }
//
//    void testSave() {
//        controller.save()
//
//        assert model.alignmentInstance != null
//        assert view == '/alignment/create'
//
//        response.reset()
//
//        populateValidParams(params)
//        controller.save()
//
//        assert response.redirectedUrl == '/alignment/show/1'
//        assert controller.flash.message != null
//        assert Alignment.count() == 1
//    }
//
//    void testShow() {
//        controller.show()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/alignment/list'
//
//
//        populateValidParams(params)
//        def alignment = new Alignment(params)
//
//        assert alignment.save() != null
//
//        params.id = alignment.id
//
//        def model = controller.show()
//
//        assert model.alignmentInstance == alignment
//    }
//
//    void testEdit() {
//        controller.edit()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/alignment/list'
//
//
//        populateValidParams(params)
//        def alignment = new Alignment(params)
//
//        assert alignment.save() != null
//
//        params.id = alignment.id
//
//        def model = controller.edit()
//
//        assert model.alignmentInstance == alignment
//    }
//
//    void testUpdate() {
//        controller.update()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/alignment/list'
//
//        response.reset()
//
//
//        populateValidParams(params)
//        def alignment = new Alignment(params)
//
//        assert alignment.save() != null
//
//        // test invalid parameters in update
//        params.id = alignment.id
//        //TODO: add invalid values to params object
//
//        controller.update()
//
//        assert view == "/alignment/edit"
//        assert model.alignmentInstance != null
//
//        alignment.clearErrors()
//
//        populateValidParams(params)
//        controller.update()
//
//        assert response.redirectedUrl == "/alignment/show/$alignment.id"
//        assert flash.message != null
//
//        //test outdated version number
//        response.reset()
//        alignment.clearErrors()
//
//        populateValidParams(params)
//        params.id = alignment.id
//        params.version = -1
//        controller.update()
//
//        assert view == "/alignment/edit"
//        assert model.alignmentInstance != null
//        assert model.alignmentInstance.errors.getFieldError('version')
//        assert flash.message != null
//    }
//
//    void testDelete() {
//        controller.delete()
//        assert flash.message != null
//        assert response.redirectedUrl == '/alignment/list'
//
//        response.reset()
//
//        populateValidParams(params)
//        def alignment = new Alignment(params)
//
//        assert alignment.save() != null
//        assert Alignment.count() == 1
//
//        params.id = alignment.id
//
//        controller.delete()
//
//        assert Alignment.count() == 0
//        assert Alignment.get(alignment.id) == null
//        assert response.redirectedUrl == '/alignment/list'
//    }
}
