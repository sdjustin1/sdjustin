describe('Page Title Test', () => {

  // homepage is working
  it('should display "Coming Soon!" in the page title element', () => {
    cy.visit('https://www.sdjustin.com/index.cfm')
    cy.get('[data-testid="pagetitle"]')
      .should("exist")
      .should('have.text', 'Coming Soon!')
  })

  // test db connectivity
  it('should justin, paul and donald as rows', () => {
    cy.visit('https://www.sdjustin.com/query.cfm')
    cy.get('.luceeH0')
      .should("exist")
      .should('have.text', 'jqueryoutput')
    cy.get(':nth-child(5) > .luceeN1')
      .should("exist")
      .should('have.text', 'donald')      
  })  

  
})