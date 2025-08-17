describe('Page Title Test', () => {

  // homepage is working
  it('should display "Coming Soon!" in the page title element', () => {
    cy.visit('https://www.sdjustin.com/index.cfm')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('contain.text', 'Coming Soon!')
  })

  // https://github.com/mnjustin/z/issues/251
  it('should make index.cfm the default index page when no page is specified', () => {
    cy.visit('https://www.sdjustin.com')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('contain.text', 'Coming Soon!')
  })  

  // https://github.com/mnjustin/z/issues/249
  it('should append www if a naked domain is requested', () => {
    cy.visit('https://sdjustin.com')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('contain.text', 'Coming Soon!')
  })    

  // https://github.com/mnjustin/z/issues/252
  it('should append the .cfm behind the scenes, making an seo friendly URL', () => {
    cy.visit('https://www.sdjustin.com/test')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('contain.text', 'test page')
  })

})