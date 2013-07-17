package ca.on.oicr.capsid



import org.junit.*
import grails.test.mixin.*

@TestFor(SampleController)
@Mock(Sample)
class SampleControllerTests {


//    def populateValidParams(params) {
//      assert params != null
//      // TODO: Populate valid properties like...
//      //params["name"] = 'someValidName'
//    }

    void testIndex() {
        controller.index()
        assert "/sample/list" == response.redirectedUrl
    }

//    void testList() {
//
//        def model = controller.list()
//
//        assert model.sampleInstanceList.size() == 0
//        assert model.sampleInstanceTotal == 0
//    }
//
//    void testCreate() {
//       def model = controller.create()
//
//       assert model.sampleInstance != null
//    }
//
//    void testSave() {
//        controller.save()
//
//        assert model.sampleInstance != null
//        assert view == '/sample/create'
//
//        response.reset()
//
//        populateValidParams(params)
//        controller.save()
//
//        assert response.redirectedUrl == '/sample/show/1'
//        assert controller.flash.message != null
//        assert Sample.count() == 1
//    }
//
//    void testShow() {
//        controller.show()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/sample/list'
//
//
//        populateValidParams(params)
//        def sample = new Sample(params)
//
//        assert sample.save() != null
//
//        params.id = sample.id
//
//        def model = controller.show()
//
//        assert model.sampleInstance == sample
//    }
//
//    void testEdit() {
//        controller.edit()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/sample/list'
//
//
//        populateValidParams(params)
//        def sample = new Sample(params)
//
//        assert sample.save() != null
//
//        params.id = sample.id
//
//        def model = controller.edit()
//
//        assert model.sampleInstance == sample
//    }
//
//    void testUpdate() {
//        controller.update()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/sample/list'
//
//        response.reset()
//
//
//        populateValidParams(params)
//        def sample = new Sample(params)
//
//        assert sample.save() != null
//
//        // test invalid parameters in update
//        params.id = sample.id
//        //TODO: add invalid values to params object
//
//        controller.update()
//
//        assert view == "/sample/edit"
//        assert model.sampleInstance != null
//
//        sample.clearErrors()
//
//        populateValidParams(params)
//        controller.update()
//
//        assert response.redirectedUrl == "/sample/show/$sample.id"
//        assert flash.message != null
//
//        //test outdated version number
//        response.reset()
//        sample.clearErrors()
//
//        populateValidParams(params)
//        params.id = sample.id
//        params.version = -1
//        controller.update()
//
//        assert view == "/sample/edit"
//        assert model.sampleInstance != null
//        assert model.sampleInstance.errors.getFieldError('version')
//        assert flash.message != null
//    }
//
//    void testDelete() {
//        controller.delete()
//        assert flash.message != null
//        assert response.redirectedUrl == '/sample/list'
//
//        response.reset()
//
//        populateValidParams(params)
//        def sample = new Sample(params)
//
//        assert sample.save() != null
//        assert Sample.count() == 1
//
//        params.id = sample.id
//
//        controller.delete()
//
//        assert Sample.count() == 0
//        assert Sample.get(sample.id) == null
//        assert response.redirectedUrl == '/sample/list'
//    }
}
