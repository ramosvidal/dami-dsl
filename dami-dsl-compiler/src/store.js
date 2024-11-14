const store = {
  products: [],
  currentProduct: null,
  currentEntity: null,
  currentConnection: null
};

function getProducts() {
  return store.products;
}

function getCurrentProduct() {
  return store.currentProduct;
}

function setCurrentProduct(productName) {
  if (!productName) {
    store.currentProduct = null;
  } else {
    store.currentProduct = getProduct(productName);
    if (!store.currentProduct) {
      throw `BIDI ${productName} does not exist!!!`;
    }
  }
}

function getCurrentEntity() {
  return store.currentEntity;
}

function setCurrentEntity(entityName) {
  if (!entityName) {
    store.currentEntity = null;
  } else {
    store.currentEntity = getCurrentProduct().getEntity(entityName);
    if (!store.currentEntity) {
      throw `Entity ${entityName} does not exist in current product!!!`;
    }
  }
}

function getCurrentConnection() {
  return store.currentConnection;
}

function setCurrentConnection(dbname) {
  if (!dbname) {
    store.currentConnection = null;
  } else {
    store.currentConnection = getCurrentProduct().getConnection(dbname);
    if (!store.currentConnection) {
      throw `Connection ${dbname} does not exist in current product!!!`;
    }
  }
}

function getProduct(name) {
  return store.products.find(e => e.name == name);
}

function addProduct(id, product) {
  store.products.push(product);
}

export default {
  getCurrentProduct,
  setCurrentProduct,
  getCurrentEntity,
  setCurrentEntity,
  getCurrentConnection,
  setCurrentConnection,
  getProducts,
  getProduct,
  addProduct
};
