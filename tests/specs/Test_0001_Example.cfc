/**
 * This is just a suite containing two very simple tests
 */
component extends="testbox.system.BaseSpec"{

    // executes before all suites
    function beforeAll(){
        FB = application.FireBolt;
    }

    // executes after all suites
    function afterAll(){}

    // All suites go in here
    function run( testResults, testBox ){

        describe("A suite", function(){
            it("contains a very simple spec", function(){
                expect( true ).toBeTrue();
            });

            it("makes sure we are running on Lucee Server", function(){
                expect( structKeyExists( server, "lucee" ) ).toBeTrue();
                expect(server).toHaveKey("lucee");
            });

            it("can access FireBolt", function(){
                expect(isObject(FB)).toBeTrue();
            });

            it("can get objects using an alias path", function(){
                local.o = FB.getObject("sampleModule@testModule");
                expect(isObject(local.o)).toBeTrue();
            });

            it("contains a sample error", function(){
                expect(false).toBeFalse();
            });
            

        });


    }
}