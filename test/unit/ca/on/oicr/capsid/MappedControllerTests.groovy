package ca.on.oicr.capsid



import org.junit.*
import grails.test.mixin.*

@TestFor(MappedController)
@Mock(Mapped)
class MappedControllerTests {


    def populateValidParams(params) {
      assert params != null
      // TODO: Populate valid properties like...
      //params["name"] = 'someValidName'
    }

    void testIndex() {
        controller.index()
        assert "/mapped/list" == response.redirectedUrl
    }

    void testList() {

        def model = controller.list()

        assert model.mappedInstanceList.size() == 0
        assert model.mappedInstanceTotal == 0
    }

    void testCreate() {
       def model = controller.create()

       assert model.mappedInstance != null
    }

    void testSave() {
        controller.save()

        assert model.mappedInstance != null
        assert view == '/mapped/create'

        response.reset()

        populateValidParams(params)
        controller.save()

        assert response.redirectedUrl == '/mapped/show/1'
        assert controller.flash.message != null
        assert Mapped.count() == 1
    }

    void testShow() {
        controller.show()

        assert flash.message != null
        assert response.redirectedUrl == '/mapped/list'


        populateValidParams(params)
        def mapped = new Mapped(params)

        assert mapped.save() != null

        params.id = mapped.id

        def model = controller.show()

        assert model.mappedInstance == mapped
    }

    void testEdit() {
        controller.edit()

        assert flash.message != null
        assert response.redirectedUrl == '/mapped/list'


        populateValidParams(params)
        def mapped = new Mapped(params)

        assert mapped.save() != null

        params.id = mapped.id

        def model = controller.edit()

        assert model.mappedInstance == mapped
    }

    void testUpdate() {
        controller.update()

        assert flash.message != null
        assert response.redirectedUrl == '/mapped/list'

        response.reset()


        populateValidParams(params)
        def mapped = new Mapped(params)

        assert mapped.save() != null

        // test invalid parameters in update
        params.id = mapped.id
        //TODO: add invalid values to params object

        controller.update()

        assert view == "/mapped/edit"
        assert model.mappedInstance != null

        mapped.clearErrors()

        populateValidParams(params)
        controller.update()

        assert response.redirectedUrl == "/mapped/show/$mapped.id"
        assert flash.message != null

        //test outdated version number
        response.reset()
        mapped.clearErrors()

        populateValidParams(params)
        params.id = mapped.id
        params.version = -1
        controller.update()

        assert view == "/mapped/edit"
        assert model.mappedInstance != null
        assert model.mappedInstance.errors.getFieldError('version')
        assert flash.message != null
    }

    void testDelete() {
        controller.delete()
        assert flash.message != null
        assert response.redirectedUrl == '/mapped/list'

        response.reset()

        populateValidParams(params)
        def mapped = new Mapped(params)

        assert mapped.save() != null
        assert Mapped.count() == 1

        params.id = mapped.id

        controller.delete()

        assert Mapped.count() == 0
        assert Mapped.get(mapped.id) == null
        assert response.redirectedUrl == '/mapped/list'
    }
}
