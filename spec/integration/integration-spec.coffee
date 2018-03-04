fs = require('fs')
zoho = require("../../lib/node-zoho")
config = require('../config.json')

# only run when we have a token
if config.authToken and config.enabled

  describe "integration", ->
    response = errors = done = za = event_id = file_id = undefined

    beforeEach ->
      response = errors = done = undefined
      za = new zoho({
        authToken: config.authToken
      })


    it "can create lead", ->
      lead =
        "Lead Source" : "Site Registration"
        "First Name"  : "Test"
        "Last Name"   : "Testerson"
        "Email"       : "test@testerson.com"

      runs ->
        za.execute('crm','Leads','insertRecords',[lead], (err, _response) ->
          errors = err
          response = _response
          done = true
        )

      waitsFor ->
        return done

      runs ->
        expect(errors).toBe(null)
        expect(response).toBeDefined()

        # expect(results.isError()).toBeFalsy()
        #

    it "can create multiple leads", ->
      lead =
        "Lead Source" : "Site Registration"
        "First Name"  : "Test"
        "Last Name"   : "Testerson"
        "Email"       : "test@testerson.com"

      runs ->
        za.execute('crm','Leads','insertRecords',[lead, lead], (err, _response) ->
          errors = err
          response = _response
          done = true
        )

      waitsFor ->
        return done

      runs ->
        expect(errors).toBe(null)
        expect(response).toBeDefined()
        expect(response.data).toBeDefined()
        expect(response.data).toEqual(jasmine.any(Array))
        expect(response.data.length).toBeGreaterThan(1)
        
    describe "events", ->
      event =
        "Subject": "Conference"
        "Start DateTime": "2014-01-01 12:30:00"
        "End DateTime": "2014-01-01 12:30:00"
        "Venue": "Mystery Theater"
        "Send Notification Email": "False"

      it "can create event", ->
        runs ->
          za.execute('crm','Events','insertRecords',[event], (err, _response) ->
            errors = err
            response = _response
            done = true
          )

        waitsFor ->
          return done

        runs ->
          event_id = response.data[0].Id
          expect(errors).toBe(null)
          expect(response).toBeDefined()

      it "can get event by id", ->
        runs ->
          za.execute('crm','Events','insertRecords',[event], (err, _response) ->
            errors = err
            response = _response
            done = true
          )

        waitsFor ->
          return done

        runs ->
          done = false
          za.execute('crm','Events','getRecordById', event_id, (err, _response) ->
            errors = err
            response = _response
            done = true
          )

        waitsFor ->
          return done

        runs ->
          expect(errors).toBe(null)
          expect(response).toBeDefined()

      it "can fetch all events", ->
        runs ->
          za.execute('crm','Events','getRecords',{}, (err, _response) ->
            errors = err
            response = _response
            done = true
          )

        waitsFor ->
          return done

        runs ->
          expect(errors).toBe(null)
          expect(response).toBeDefined()
          expect(response.data).toEqual(jasmine.any(Array))

    describe "attachment", ->
      file = "https://picsum.photos/200/300/?random"
      
      it "can upload file", ->
        runs ->
          za.execute('crm','Events','uploadFile', event_id, file, false, (err, _response) ->
            errors = err
            response = _response
            done = true
          )

        waitsFor ->
          return done

        runs ->
          file_id = response.data.Id
          expect(errors).toBe(null)
          expect(response).toBeDefined()
          expect(response.data).toBeDefined()
          expect(response.data.Id).toBeDefined()

      it "canot download attachment of type Link", ->
        runs ->
          za.execute('crm','Events','downloadFile',file_id, (err, _response) ->
            errors = err
            response = _response
            done = true
          )

        waitsFor ->
          return done

        runs ->
          expect(errors).toBeDefined()
          expect(errors.code).toBeDefined()
          expect(errors.message).toBeDefined()

      it "can delete file", ->
        runs ->
          za.execute('crm','Events','deleteFile', file_id, (err, _response) ->
            errors = err
            response = _response
            done = true
          )

        waitsFor ->
          return done

        runs ->
          expect(errors).toBe(null)
          expect(response).toBeDefined()
          expect(response.data).toBeDefined()
          expect(response.data.success).toBeDefined()

    if config.image
      describe "files", ->
        descriptor = config.image
        file = fs.readFileSync(descriptor)
        it "can upload file", ->
          runs ->
            za.execute('crm','Events','uploadFile', event_id, file, descriptor, (err, _response) ->
              errors = err
              response = _response
              done = true
            )

          waitsFor ->
            return done

          runs ->
            file_id = response.data.Id
            expect(errors).toBe(null)
            expect(response).toBeDefined()
            expect(response.data).toBeDefined()
            expect(response.data.Id).toBeDefined()

        it "can download file", ->
          runs ->
            za.execute('crm','Events','downloadFile',file_id, (err, _response) ->
              errors = err
              response = _response
              done = true
            )

          waitsFor ->
            return done

          runs ->
            expect(errors).toBe(null)
            expect(response).toBeDefined()
            expect(response.data).toBeDefined()
            expect(response.data.buffer).toBeDefined()

        it "can delete file", ->
          runs ->
            za.execute('crm','Events','deleteFile', file_id, (err, _response) ->
              errors = err
              response = _response
              done = true
            )

          waitsFor ->
            return done

          runs ->
            expect(errors).toBe(null)
            expect(response).toBeDefined()
            expect(response.data).toBeDefined()
            expect(response.data.success).toBeDefined()

