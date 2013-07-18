package ca.on.oicr.capsid



import org.junit.*
import grails.test.mixin.*

@TestFor(GenomeController)
@Mock(Genome)
class GenomeControllerTests {


//    def populateValidParams(params) {
//      assert params != null
//      // TODO: Populate valid properties like...
//      //params["name"] = 'someValidName'
//    }

    void testIndex() {
        controller.index()
        assert "/genome/list" == response.redirectedUrl
    }

//    void testList() {
//
//        def model = controller.list()
//
//        assert model.genomeInstanceList.size() == 0
//        assert model.genomeInstanceTotal == 0
//    }
//
//    void testCreate() {
//       def model = controller.create()
//
//       assert model.genomeInstance != null
//    }
//
//    void testSave() {
//        controller.save()
//
//        assert model.genomeInstance != null
//        assert view == '/genome/create'
//
//        response.reset()
//
//        populateValidParams(params)
//        controller.save()
//
//        assert response.redirectedUrl == '/genome/show/1'
//        assert controller.flash.message != null
//        assert Genome.count() == 1
//    }
//
//    void testShow() {
//        controller.show()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/genome/list'
//
//
//        populateValidParams(params)
//        def genome = new Genome(params)
//
//        assert genome.save() != null
//
//        params.id = genome.id
//
//        def model = controller.show()
//
//        assert model.genomeInstance == genome
//    }
//
//    void testEdit() {
//        controller.edit()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/genome/list'
//
//
//        populateValidParams(params)
//        def genome = new Genome(params)
//
//        assert genome.save() != null
//
//        params.id = genome.id
//
//        def model = controller.edit()
//
//        assert model.genomeInstance == genome
//    }
//
//    void testUpdate() {
//        controller.update()
//
//        assert flash.message != null
//        assert response.redirectedUrl == '/genome/list'
//
//        response.reset()
//
//
//        populateValidParams(params)
//        def genome = new Genome(params)
//
//        assert genome.save() != null
//
//        // test invalid parameters in update
//        params.id = genome.id
//        //TODO: add invalid values to params object
//
//        controller.update()
//
//        assert view == "/genome/edit"
//        assert model.genomeInstance != null
//
//        genome.clearErrors()
//
//        populateValidParams(params)
//        controller.update()
//
//        assert response.redirectedUrl == "/genome/show/$genome.id"
//        assert flash.message != null
//
//        //test outdated version number
//        response.reset()
//        genome.clearErrors()
//
//        populateValidParams(params)
//        params.id = genome.id
//        params.version = -1
//        controller.update()
//
//        assert view == "/genome/edit"
//        assert model.genomeInstance != null
//        assert model.genomeInstance.errors.getFieldError('version')
//        assert flash.message != null
//    }
//
//    void testDelete() {
//        controller.delete()
//        assert flash.message != null
//        assert response.redirectedUrl == '/genome/list'
//
//        response.reset()
//
//        populateValidParams(params)
//        def genome = new Genome(params)
//
//        assert genome.save() != null
//        assert Genome.count() == 1
//
//        params.id = genome.id
//
//        controller.delete()
//
//        assert Genome.count() == 0
//        assert Genome.get(genome.id) == null
//        assert response.redirectedUrl == '/genome/list'
//    }
}
