jQuery ->
  $('#department').remoteChained('#building', '/assets/departments.json')
  $('#user').remoteChained('#department', '/assets/users.json')
