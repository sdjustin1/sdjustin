describe('Page Title Test', () => {

  // homepage is working
  it('should display "Coming Soon!" in the page title element', () => {
    cy.visit('https://www.sdjustin.com/index.cfm')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('have.text', 'Coming Soon!')
  })


  
})