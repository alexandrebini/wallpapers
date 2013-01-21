App.Store = DS.Store.extend
  revision: 11
  adapter: DS.RESTAdapter.create({ bulkCommit: false, namespace: 'admin' })