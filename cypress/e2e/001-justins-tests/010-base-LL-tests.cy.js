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

  // test cfhttp
  it('should request aws.amazon.com and dump response', () => {
    cy.visit('https://www.sdjustin.com/cfhttp.cfm')
    cy.get('.luceeH3')
      .should("exist")
      .should('have.text', 'jcfhttpdump')
      cy.get('.luceeN3 > :nth-child(1) > :nth-child(1) > :nth-child(6) > .luceeN2 > table > tbody > tr > .luceeN1')
      .should("exist")
      .should('contain.text', '<title>Cloud Computing Services - Amazon Web Services (AWS)</title>')      
  })    
    
})