import client from "./client";

export const authApi = {
  register: (payload) => client.post("/auth/register", payload),
  login: (payload) => client.post("/auth/login", payload),
  me: () => client.get("/auth/me"),
  updateMe: (payload) => client.patch("/auth/me", payload),
};

export const catalogApi = {
  categories: () => client.get("/categories"),
  productTypes: () => client.get("/product-types"),
  products: (params) => client.get("/products", { params }),
  product: (id) => client.get(`/products/${id}`),
  popular: (limit = 8) => client.get("/products/popular", { params: { limit } }),
};

export const ratingsApi = {
  set: (productId, stars) =>
    client.post(`/products/${productId}/rating`, { stars }),
  mine: (productId) => client.get(`/products/${productId}/rating/mine`),
};

export const reviewsApi = {
  list: (productId) => client.get(`/products/${productId}/reviews`),
  create: (productId, payload) =>
    client.post(`/products/${productId}/reviews`, payload),
  canLeave: (productId) =>
    client.get(`/products/${productId}/reviews/can-leave`),
  promoted: () => client.get("/reviews/promoted"),
};

export const cartApi = {
  get: () => client.get("/cart"),
  add: (productId, quantity = 1) =>
    client.post("/cart", { product_id: productId, quantity }),
  update: (itemId, quantity) =>
    client.patch(`/cart/${itemId}`, { quantity }),
  remove: (itemId) => client.delete(`/cart/${itemId}`),
  clear: () => client.delete("/cart"),
};

export const favoritesApi = {
  list: () => client.get("/favorites"),
  add: (productId) => client.post("/favorites", { product_id: productId }),
  remove: (productId) => client.delete(`/favorites/${productId}`),
  ids: () => client.get("/favorites/ids"),
};

export const ordersApi = {
  checkout: (payload) => client.post("/orders/checkout", payload),
  list: () => client.get("/orders"),
  detail: (id) => client.get(`/orders/${id}`),
};

export const adminApi = {
  listCategories: () => client.get("/admin/categories"),
  createCategory: (data) => client.post("/admin/categories", data),
  updateCategory: (id, data) => client.put(`/admin/categories/${id}`, data),
  deleteCategory: (id) => client.delete(`/admin/categories/${id}`),
  listTypes: () => client.get("/admin/product-types"),
  createType: (data) => client.post("/admin/product-types", data),
  updateType: (id, data) => client.put(`/admin/product-types/${id}`, data),
  deleteType: (id) => client.delete(`/admin/product-types/${id}`),
  listProducts: () => client.get("/admin/products"),
  createProduct: (data) => client.post("/admin/products", data),
  updateProduct: (id, data) => client.put(`/admin/products/${id}`, data),
  deleteProduct: (id) => client.delete(`/admin/products/${id}`),
  uploadImage: (productId, file) => {
    const fd = new FormData();
    fd.append("file", file);
    return client.post(`/admin/products/${productId}/images`, fd, {
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
  deleteImage: (imageId) => client.delete(`/admin/images/${imageId}`),
  listOrders: (params) => client.get("/admin/orders", { params }),
  orderDetail: (id) => client.get(`/admin/orders/${id}`),
  changeStatus: (id, status) =>
    client.patch(`/admin/orders/${id}/status`, { status }),
  statuses: () => client.get("/admin/statuses"),
  listUsers: () => client.get("/admin/users"),
  updateUser: (id, data) => client.patch(`/admin/users/${id}`, data),
  changeUserRole: (id, role) =>
    client.patch(`/admin/users/${id}/role`, { role }),
  listReviews: () => client.get("/admin/reviews"),
  createReview: (payload) => client.post("/admin/reviews", payload),
  updateReview: (id, payload) => client.patch(`/admin/reviews/${id}`, payload),
  deleteReview: (id) => client.delete(`/admin/reviews/${id}`),
};
