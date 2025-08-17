describe('Page Title Test', () => {

  // https://github.com/mnjustin/z/issues/251
  it('should make index.cfm the default index page when no page is specified', () => {
    cy.visit('https://www.sdjustin.com')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('have.text', 'Coming Soon!')
  })  

  // https://github.com/mnjustin/z/issues/249
  it('should append www if a naked domain is requested', () => {
    cy.visit('https://sdjustin.com')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('have.text', 'Coming Soon!')
  })    

  // https://github.com/mnjustin/z/issues/252
  it('should append the .cfm behind the scenes, making an seo friendly URL', () => {
    cy.visit('https://www.sdjustin.com/test')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('have.text', 'test page')
  })

  // https://github.com/mnjustin/z/issues/295
  it('should find the test file in the folder and return it to the user', () => {
    cy.visit('https://www.sdjustin.com/somefolder/jtest.cfm')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('have.text', 'subfolder test page')
  })
  
  // https://github.com/mnjustin/z/issues/250
  it('redirect http requests to https', () => {
    cy.visit('http://sdjustin.com/index.cfm')
    cy.get('[data-testid="pagetitle"]')
    .should("exist")
    .should('have.text', 'Coming Soon!')
  })

  // https://github.com/mnjustin/z/issues/250
  it('redirect http requests to https', () => {
    cy.visit('http://www.sdjustin.com/index.cfm')
    cy.get('[data-testid="pagetitle"]')
    .should("exist")
    .should('have.text', 'Coming Soon!')
  })  
  
})