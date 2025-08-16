describe('Page Title Test', () => {
  it('should display "Coming Soon!" in the page title element', () => {
    cy.visit('https://www.sdjustin.com/index.cfm')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('contain.text', 'Coming Soon!')
  })

  
  it('should append the .cfm behind the scenes, making an seo friendly URL', () => {
    cy.visit('https://www.sdjustin.com/test')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('contain.text', 'test page')
  })


})