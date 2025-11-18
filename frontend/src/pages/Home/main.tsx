import { useNavigate } from 'react-router-dom';

export const HomePage = () => {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-8">
      <div className="text-center max-w-2xl">
        <h1 className="text-5xl font-bold text-gray-900 mb-4">Bem-vindo ao BookNest</h1>
        <p className="text-xl text-gray-600 mb-8">
          Sua biblioteca pessoal e clube de leitura virtual
        </p>
        <p className="text-gray-500 mb-8">
          Organize seus livros, acompanhe suas leituras e alcance suas metas literárias.
        </p>

        <div className="flex gap-4 justify-center">
          <button
            onClick={() => navigate('/library')}
            className="px-8 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium text-lg"
          >
            Minha Biblioteca
          </button>
          <button
            onClick={() => navigate('/dashboard')}
            className="px-8 py-3 bg-white text-blue-600 border-2 border-blue-600 rounded-lg hover:bg-blue-50 transition-colors font-medium text-lg"
          >
            Ver Dashboard
          </button>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
