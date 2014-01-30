package ca.on.oicr.capsid



import org.junit.*
import grails.test.mixin.*

@TestFor(FeatureController)
@Mock(Feature)
class FeatureControllerTests {


//    def populateValidParams(params) {
//      assert params != null
//      // TODO: Populate valid properties like...
//      //params["name"] = 'someValidName'
//    }

    void testIndex() {
        controller.index()
        assert "/feature/list" == response.redirectedUrl
    }

//    void testList() {
//
//        def model = controller.list()
//
//        assert model.featureInstanceList.size() == 0
//        assert model.featureInstanceTotal == 0
//    }
//
//    void testCreate() {
//       def model = controller.create()
//
//       assert model.featureInstance != null
//    }
//
//    void testSave() {
//        controller.save()
//
//        assert model.featureInstance != null
//        assert view == '/feature/create'
//
//        response.reset()
//
//        populateValidParams(params)
//        controller.save()
//
//        assert response.redirectedUrl == '/feature/show/1'
//        assert controller.flash.message != null
//        assert Feature.count() == 1
//    }
//
//    void testShow() {
//        controller.show()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/feature/list'
//
//
//        populateValidParams(params)
//        def feature = new Feature(params)
//
//        assert feature.save() != null
//
//        params.id = feature.id
//
//        def model = controller.show()
//
//        assert model.featureInstance == feature
//    }
//
//    void testEdit() {
//        controller.edit()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/feature/list'
//
//
//        populateValidParams(params)
//        def feature = new Feature(params)
//
//        assert feature.save() != null
//
//        params.id = feature.id
//
//        def model = controller.edit()
//
//        assert model.featureInstance == feature
//    }
//
//    void testUpdate() {
//        controller.update()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/feature/list'
//
//        response.reset()
//
//
//        populateValidParams(params)
//        def feature = new Feature(params)
//
//        assert feature.save() != null
//
//        // test invalid parameters in update
//        params.id = feature.id
//        //TODO: add invalid values to params object
//
//        controller.update()
//
//        assert view == "/feature/edit"
//        assert model.featureInstance != null
//
//        feature.clearErrors()
//
//        populateValidParams(params)
//        controller.update()
//
//        assert response.redirectedUrl == "/feature/show/$feature.id"
//        assert flash.message != null
//
//        //test outdated version number
//        response.reset()
//        feature.clearErrors()
//
//        populateValidParams(params)
//        params.id = feature.id
//        params.version = -1
//        controller.update()
//
//        assert view == "/feature/edit"
//        assert model.featureInstance != null
//        assert model.featureInstance.errors.getFieldError('version')
//        assert flash.message != null
//    }
//
//    void testDelete() {
//        controller.delete()
//        assert flash.message != null
//        assert response.redirectedUrl == '/feature/list'
//
//        response.reset()
//
//        populateValidParams(params)
//        def feature = new Feature(params)
//
//        assert feature.save() != null
//        assert Feature.count() == 1
//
//        params.id = feature.id
//
//        controller.delete()
//
//        assert Feature.count() == 0
//        assert Feature.get(feature.id) == null
//        assert response.redirectedUrl == '/feature/list'
//    }
}
