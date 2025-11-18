/**
 * @page HomePage
 * @summary Welcome page for BookNest application.
 * @domain core
 * @type landing-page
 * @category public
 */
export const HomePage = () => {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-8">
      <div className="text-center max-w-2xl">
        <h1 className="text-5xl font-bold text-gray-900 mb-4">Bem-vindo ao BookNest</h1>
        <p className="text-xl text-gray-600 mb-8">
          Sua biblioteca pessoal e clube de leitura virtual
        </p>
        <p className="text-gray-500">
          Organize seus livros, acompanhe suas leituras e alcance suas metas literárias.
        </p>
      </div>
    </div>
  );
};

export default HomePage;
